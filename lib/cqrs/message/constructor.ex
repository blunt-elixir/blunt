defmodule Cqrs.Message.Constructor do
  @moduledoc false

  alias Ecto.Changeset
  alias Cqrs.Message.Input
  alias __MODULE__, as: Constructor
  alias Cqrs.Message.Changeset, as: MessageChangeset

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      constructor = Keyword.get(opts, :constructor, :new)
      Module.put_attribute(__MODULE__, :constructor, constructor)
    end
  end

  defmacro generate do
    quote do
      constructor_info = %{
        name: @constructor,
        has_fields?: @primary_key_type != false || Enum.count(@schema_fields) > 0,
        has_required_fields?: @primary_key_type != false || Enum.count(@required_fields) > 0
      }

      Module.eval_quoted(__MODULE__, Constructor.do_generate(constructor_info))
    end
  end

  def do_generate(%{name: name, has_fields?: true, has_required_fields?: true}) do
    quote do
      @type constructor_values :: Input.t()
      @type constructor_overrides :: Input.t()

      @spec unquote(name)(constructor_values, constructor_overrides) :: {:ok, struct(), map()} | {:error, any()}

      def unquote(name)(values, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def do_generate(%{name: name, has_fields?: true}) do
    quote do
      @type constructor_values :: Input.t()
      @type constructor_overrides :: Input.t()

      @spec unquote(name)(constructor_values, constructor_overrides) :: {:ok, struct(), map()} | {:error, any()}

      def unquote(name)(values \\ %{}, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def do_generate(%{name: name}) do
    quote do
      @spec unquote(name)() :: {:ok, struct(), map()} | {:error, any()}

      def unquote(name)(),
        do: Constructor.apply(__MODULE__, %{}, %{})
    end
  end

  def apply(module, values, overrides) do
    values = Input.normalize(values, module)
    overrides = Input.normalize(overrides, module)

    input = Map.merge(values, overrides)

    with {:ok, message, discarded_data} <- input |> module.changeset() |> handle_changeset() do
      {:ok, module.after_validate(message), discarded_data}
    end
  end

  def handle_changeset({%{valid?: false} = changeset, _discarded_data}),
    do: {:error, MessageChangeset.format_errors(changeset)}

  def handle_changeset({changeset, discarded_data}),
    do: {:ok, Changeset.apply_action!(changeset, :create), discarded_data}
end
