defmodule Cqrs.Message do
  alias Cqrs.Config
  alias Cqrs.Message.{Changeset, Contstructor, Dispatch, Field, Metadata, Reflection, Schema, Version}

  import Cqrs.Message.Opts

  @type changeset :: Ecto.Changeset.t()

  @callback handle_validate(changeset()) :: changeset()
  @callback after_validate(struct()) :: struct()

  defmacro __using__(opts \\ []) do
    quote do
      primary_key = primary_key(unquote(opts))
      dispatch? = Keyword.get(unquote(opts), :dispatch?, false)
      constructor = Keyword.get(unquote(opts), :constructor, :new)
      message_type = Keyword.get(unquote(opts), :message_type, :message)
      create_jason_encoders? = Config.create_jason_encoders?(unquote(opts))
      require_all_fields? = Keyword.get(unquote(opts), :require_all_fields?, false)

      Version.register(__MODULE__, unquote(opts))

      Module.register_attribute(__MODULE__, :schema_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :required_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :metadata, accumulate: true, persist: true)

      Module.put_attribute(__MODULE__, :dispatch?, dispatch?)
      Module.put_attribute(__MODULE__, :constructor, constructor)
      Module.put_attribute(__MODULE__, :message_type, message_type)
      Module.put_attribute(__MODULE__, :primary_key_type, primary_key)
      Module.put_attribute(__MODULE__, :require_all_fields?, require_all_fields?)
      Module.put_attribute(__MODULE__, :create_jason_encoders?, create_jason_encoders?)

      import Cqrs.Message, only: :macros

      @behaviour Cqrs.Message
      @before_compile Cqrs.Message
      @metadata dispatchable?: dispatch?

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
    constructor =
      quote do
        Contstructor.generate(%{
          name: @constructor,
          has_fields?: @primary_key_type != false || Enum.count(@schema_fields) > 0,
          has_required_fields?: @primary_key_type != false || Enum.count(@required_fields) > 0
        })
      end

    quote location: :keep do
      require Cqrs.Message.{Changeset, Dispatch, Reflection, Schema}

      Version.generate(__MODULE__)
      Module.eval_quoted(__MODULE__, unquote(constructor))

      Schema.generate()
      Changeset.generate()
      Reflection.generate()

      if @dispatch? do
        Dispatch.generate()
      end
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
      {:ok, module} -> Metadata.fetch!(module, :dispatchable?)
      _ -> false
    end
  end
end
