defmodule Blunt.Message do
  require Logger

  @moduledoc """
  This is the main building block of all messages.

  I think this should go away and have other messages just compose
  what they need using the macros in here.

  ## Options

  * message_type - required atom
  * create_jason_encoders? - default value: `true`
  * require_all_fields? - default value: `false`
  * versioned? - default value: `false`
  * dispatch? - default value: `false`
  * primary_key - default value: `false`
  * constructor - default value: `:new`
  """

  alias Blunt.Message.{
    Changeset,
    Constructor,
    Dispatch,
    Documentation,
    Metadata,
    PrimaryKey,
    Schema,
    Schema.Fields,
    Version
  }

  defmodule Error do
    defexception [:message]
  end

  @type changeset :: Ecto.Changeset.t()

  @callback before_validate(map()) :: map()
  @callback handle_validate(changeset()) :: changeset()
  @callback after_validate(struct()) :: struct()

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      use Blunt.Message.Compilation

      require Blunt.Message.{
        Constructor,
        Changeset,
        Dispatch,
        Documentation,
        Schema,
        Schema.Fields,
        Metadata,
        PrimaryKey,
        Version
      }

      Metadata.register(opts)
      Schema.register(opts)
      Version.register(opts)
      Dispatch.register(opts)
      PrimaryKey.register(opts)
      Constructor.register(opts)

      import Blunt.Message, only: :macros

      @behaviour Blunt.Message
      @before_compile Blunt.Message

      if opts[:keep_discarded_data] do
        @schema_fields {:discarded_data, :map, required: false, internal: true, virtual: true}
      end

      @impl true
      def handle_validate(changeset), do: changeset

      @impl true
      def after_validate(message), do: message

      @impl true
      def before_validate(values), do: values

      defoverridable handle_validate: 1, after_validate: 1, before_validate: 1
    end
  end

  defmacro __before_compile__(env) do
    [
      Documentation.generate_module_doc(env),
      Version.generate(env),
      PrimaryKey.generate(env),
      Constructor.generate(env),
      Schema.generate(env),
      Changeset.generate(),
      Dispatch.generate(),
      Metadata.generate()
    ]
  end

  @spec field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro field(name, type, opts \\ []),
    do: Fields.record(name, type, opts)

  @spec require_at_least_one(list(atom())) :: any()
  defmacro require_at_least_one(fields) when is_list(fields),
    do: Schema.require_at_least_one(fields)

  @spec require_either(list(atom | list(atom))) :: any()
  defmacro require_either(fields) when is_list(fields),
    do: Schema.require_either(fields)

  @spec metadata(atom(), any()) :: any()
  defmacro metadata(name, value),
    do: Metadata.record(name, value)

  @spec internal_field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro internal_field(name, type, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:internal, true)
      |> Keyword.put(:required, false)

    Fields.record(name, type, opts)
  end

  def dispatchable?(%{__struct__: module}),
    do: dispatchable?(module)

  def dispatchable?(module) do
    case Blunt.Behaviour.validate(module, __MODULE__) do
      {:ok, module} -> Metadata.dispatchable?(module)
      _ -> false
    end
  end

  @doc false
  defdelegate compile_start(message_module), to: Blunt.Message.Compilation
end
