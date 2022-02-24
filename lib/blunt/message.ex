defmodule Blunt.Message do
  require Logger

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

  @callback handle_validate(changeset()) :: changeset()
  @callback after_validate(struct()) :: struct()

  @moduledoc """
  ## Options

  * message_type - required atom
  * create_jason_encoders? - default value: `true`
  * require_all_fields? - default value: `false`
  * versioned? - default value: `false`
  * dispatch? - default value: `false`
  * primary_key - default value: `false`
  * constructor - default value: `:new`
  """

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

      @impl true
      def handle_validate(changeset),
        do: changeset

      @impl true
      def after_validate(message),
        do: message

      defoverridable handle_validate: 1, after_validate: 1
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

  defdelegate compile_start(message_module), to: Blunt.Message.Compilation
end
