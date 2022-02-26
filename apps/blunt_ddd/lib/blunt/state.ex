defmodule Blunt.State do
  @moduledoc false

  alias Blunt.{Error, State}
  alias Blunt.Message.{Changeset, Schema, Schema.Fields}

  defmodule Error do
    defexception [:errors]

    def message(%{errors: errors}) do
      inspect(errors)
    end
  end

  defmacro __using__(_opts) do
    quote do
      use Blunt.Message.Compilation

      @primary_key_type false
      @require_all_fields? false
      @create_jason_encoders? false

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)

      @before_compile Blunt.State

      import Blunt.State, only: :macros
    end
  end

  @spec field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro field(name, type, opts \\ []),
    do: Fields.record(name, type, opts)

  defmacro __before_compile__(env) do
    schema = Schema.generate(env)
    state_update = State.generate_update()
    field_access_functions = State.generate_field_access_functions(env)

    [schema, state_update] ++ field_access_functions
  end

  @doc false
  def generate_field_access_functions(%{module: module}) do
    module
    |> Module.get_attribute(:schema_fields)
    |> Enum.map(&generate_field_access/1)
  end

  @doc false
  defp generate_field_access({name, _type, _config}) do
    getter = String.to_atom("get_#{name}")
    putter = String.to_atom("put_#{name}")

    quote do
      def unquote(getter)(%__MODULE__{} = state) do
        Map.fetch!(state, unquote(name))
      end

      def unquote(putter)(%__MODULE__{} = state, value) do
        State.put(__MODULE__, state, unquote(name), value)
      end
    end
  end

  @doc false
  def generate_update do
    quote do
      def update(%__MODULE__{} = state, values) do
        State.update(__MODULE__, state, values)
      end
    end
  end

  @doc false
  def update(state_module, state, values) do
    attrs = Blunt.Message.Input.normalize(values, state_module)

    types =
      :fields
      |> state_module.__schema__()
      |> Enum.into(%{}, fn field -> {field, state_module.__schema__(:type, field)} end)

    case Ecto.Changeset.cast({state, types}, attrs, Map.keys(types)) do
      %{valid?: true} = changeset -> Ecto.Changeset.apply_changes(changeset)
      changeset -> raise Error, errors: Changeset.format_errors(changeset)
    end
  end

  @doc false
  def put(state_module, state, key, value),
    do: update(state_module, state, Map.new([{key, value}]))
end
