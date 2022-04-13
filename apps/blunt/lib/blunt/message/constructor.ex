defmodule Blunt.Message.Constructor do
  @moduledoc false

  alias Ecto.Changeset
  alias __MODULE__, as: Constructor
  alias Blunt.Message.{Documentation, Input}
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
    schema_fields = Module.get_attribute(module, :schema_fields)
    required_fields = Module.get_attribute(module, :required_fields)

    constructor_info = %{
      name: constructor,
      docs: doc,
      has_fields?: pk_type != false || Enum.count(schema_fields) > 0,
      has_required_fields?: pk_type != false || Enum.count(required_fields) > 0
    }

    Constructor.do_generate(constructor_info)
  end

  # defp type_spec(schema_fields) do
  #   {required, optional} = Enum.split_with(schema_fields, fn {_name, _type, config} ->
  #     Keyword.get(config, :required) == true
  #   end)
  # end

  def do_generate(%{has_fields?: true, has_required_fields?: true, name: name, docs: docs}) do
    quote do
      @type input :: map() | struct() | keyword()

      @spec unquote(name)(input, input) :: {:ok, struct()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(values, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def do_generate(%{has_fields?: true, name: name, docs: docs}) do
    quote do
      @type input :: map() | struct() | keyword()

      @spec unquote(name)(input, input) :: {:ok, struct()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(values \\ %{}, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def do_generate(%{name: name, docs: docs}) do
    quote do
      @spec unquote(name)() :: {:ok, struct()} | {:error, any()}
      @doc unquote(docs)
      def unquote(name)(),
        do: Constructor.apply(__MODULE__, %{}, %{})
    end
  end

  def apply(module, values, overrides) do
    values = Input.normalize(values, module)
    overrides = Input.normalize(overrides, module)

    input =
      values
      |> Map.merge(overrides)
      |> module.before_validate()

    with {:ok, message} <- input |> module.changeset() |> handle_changeset() do
      {:ok, module.after_validate(message)}
    end
  end

  def handle_changeset({%{valid?: false} = changeset, _discarded_data}),
    do: {:error, MessageChangeset.format_errors(changeset)}

  def handle_changeset({changeset, discarded_data}) do
    message =
      changeset
      |> Changeset.put_change(:discarded_data, discarded_data)
      |> Changeset.apply_action!(:create)

    {:ok, message}
  end
end
