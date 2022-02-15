defmodule Cqrs.Message do
  alias Cqrs.Message.{Changeset, Constructor, Documentation, Dispatch, Field, Metadata, PrimaryKey, Schema, Version}

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
      require Cqrs.Message.{Changeset, Constructor, Documentation, Dispatch, Schema, Metadata, PrimaryKey, Version}

      Metadata.register(opts)
      Schema.register(opts)
      Version.register(opts)
      Dispatch.register(opts)
      PrimaryKey.register(opts)
      Constructor.register(opts)

      import Cqrs.Message, only: :macros

      @behaviour Cqrs.Message
      @before_compile Cqrs.Message

      @impl true
      def handle_validate(changeset),
        do: changeset

      @impl true
      def after_validate(message),
        do: message

      defoverridable after_validate: 1
    end
  end

  defmacro __before_compile__(_env) do
    quote location: :keep do
      Documentation.generate()
      Version.generate()
      PrimaryKey.generate()
      Constructor.generate()
      Schema.generate()
      Changeset.generate()
      Metadata.generate()
      Dispatch.generate()
    end
  end

  @spec field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro field(name, type, opts \\ []),
    do: Field.record(name, type, opts)

  @spec metadata(atom(), any()) :: any()
  defmacro metadata(name, value),
    do: Metadata.record(name, value)

  @spec internal_field(name :: atom(), type :: atom(), keyword()) :: any()
  defmacro internal_field(name, type, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:internal, true)
      |> Keyword.put(:required, false)

    Field.record(name, type, opts)
  end

  def dispatchable?(%{__struct__: module}),
    do: dispatchable?(module)

  def dispatchable?(module) do
    case Cqrs.Behaviour.validate(module, __MODULE__) do
      {:ok, module} -> Metadata.dispatchable?(module)
      _ -> false
    end
  end
end
