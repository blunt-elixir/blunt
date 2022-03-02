defmodule Blunt.Message.Schema.DefaultFieldProvider do
  @behaviour Blunt.Message.Schema.FieldProvider

  alias Blunt.Behaviour
  alias Blunt.Message.Schema.{FieldProvider, Fields}

  @impl true
  def validate_changeset(validation, field_name, changeset, module) do
    validation = IO.ANSI.format([:blue, inspect(validation), :reset])
    field = IO.ANSI.format([:blue, inspect(module), ".", to_string(field_name), :reset])
    IO.puts("unable to locate the #{validation} validator for #{field}\n")
    changeset
  end

  @impl true
  def ecto_field(module, {name, type, opts}) do
    quote bind_quoted: [module: module, name: name, type: type, opts: opts] do
      case {name, type, opts} do
        {name, :binary_id, opts} ->
          Ecto.Schema.field(name, Ecto.UUID, opts)

        {name, :enum, opts} ->
          Ecto.Schema.field(name, Ecto.Enum, opts)

        {name, {:array, :enum}, opts} ->
          Ecto.Schema.field(name, {:array, Ecto.Enum}, opts)

        {name, {:array, type}, opts} ->
          if Fields.embedded?(type),
            do: Ecto.Schema.embeds_many(name, type),
            else: Ecto.Schema.field(name, {:array, type}, opts)

        {name, type, opts} ->
          case Behaviour.validate(type, FieldProvider) do
            {:ok, provider} ->
              provider.ecto_field(module, {name, type, opts})

            _otherwise ->
              if Fields.embedded?(type),
                do: Ecto.Schema.embeds_one(name, type),
                else: Ecto.Schema.field(name, type, opts)
          end
      end
    end
  end

  @impl true
  def fake(type, validation, config) do
    Blunt.Data.Factories.FakeProvider.fake(type, validation, config)
  end
end
