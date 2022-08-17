defmodule Blunt.Message.Constructor do
  @moduledoc false

  alias Ecto.Changeset
  alias __MODULE__, as: Constructor
  alias Blunt.Message.{Documentation, Input, Options}
  alias Blunt.Message.Changeset, as: MessageChangeset

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      constructor = Keyword.get(opts, :constructor, :new)
      Module.put_attribute(__MODULE__, :constructor, constructor)
    end
  end

  def generate(%{module: module}) do
    constructor = Module.get_attribute(module, :constructor)
    doc = Documentation.generate_constructor_doc(module)
    pk_type = Module.get_attribute(module, :primary_key_type)

    schema_fields =
      Module.get_attribute(module, :schema_fields)
      |> Enum.reject(&match?({:__blunt_id, _type, _opts}, &1))

    required_fields = Module.get_attribute(module, :required_fields)

    constructor_info = %{
      name: constructor,
      docs: doc,
      has_fields?: pk_type != false || Enum.count(schema_fields) > 0,
      has_required_fields?: pk_type != false || Enum.count(required_fields) > 0
    }

    Constructor.do_generate(constructor_info)
  end

  def do_generate(%{has_fields?: true, has_required_fields?: true, name: name, docs: docs}) do
    quote do
      @type input :: map() | struct() | keyword()

      @spec unquote(name)(input, input, keyword) :: {:ok, t()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(values, overrides \\ [], opts \\ []) when (is_list(values) or is_map(values)) and is_list(opts),
        do: Constructor.apply(__MODULE__, values, overrides, opts)
    end
  end

  def do_generate(%{has_fields?: true, name: name, docs: docs}) do
    quote do
      @type input :: map() | struct() | keyword()

      @spec unquote(name)(input, input, keyword) :: {:ok, t()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(values \\ %{}, overrides \\ [], opts \\ [])
          when (is_list(values) or is_map(values)) and is_list(opts),
          do: Constructor.apply(__MODULE__, values, overrides, opts)
    end
  end

  def do_generate(%{name: name, docs: docs}) do
    quote do
      @spec unquote(name)(keyword) :: {:ok, t()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(opts \\ []) when is_list(opts),
        do: Constructor.apply(__MODULE__, %{}, %{}, opts)
    end
  end

  def apply(module, values, overrides, opts) do
    values = Input.normalize(values, module)
    overrides = Input.normalize(overrides, module)
    input = Map.merge(values, overrides)

    with {:ok, opts} <- Options.Parser.parse_message_opts(module, opts),
         {:ok, message} <- input |> module.changeset(opts) |> handle_changeset() do
      {:ok, module.after_validate(message)}
    end
  end

  defp handle_changeset(%{valid?: false} = changeset),
    do: {:error, MessageChangeset.format_errors(changeset)}

  defp handle_changeset(changeset) do
    {:ok, Changeset.apply_action!(changeset, :create)}
  end
end
