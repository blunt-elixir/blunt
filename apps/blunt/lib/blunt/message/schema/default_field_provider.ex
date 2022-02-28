defmodule Blunt.Message.Schema.DefaultFieldProvider do
  @behaviour Blunt.Message.Schema.FieldProvider
  alias Blunt.Message.Schema.Fields

  @impl true
  def validate_changeset(validation, field_name, changeset, module) do
    validation = IO.ANSI.format([:blue, inspect(validation), :reset])
    field = IO.ANSI.format([:blue, inspect(module), ".", to_string(field_name), :reset])
    IO.puts("unable to locate the #{validation} validator for #{field}\n")
    changeset
  end

  @impl true
  def ecto_field(_module, {name, type, opts}) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
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
          if Fields.embedded?(type),
            do: Ecto.Schema.embeds_one(name, type),
            else: Ecto.Schema.field(name, type, opts)
      end
    end
  end

  @impl true
  def fake(type, validation, config) do
    case type do
      :any -> Faker.Person.suffix()
      :binary -> nil
      :boolean -> Enum.random([true, false])
      :date -> Faker.Date.between(~D[2000-01-01], Date.utc_today())
      :decimal -> Faker.Commerce.price()
      :float -> Faker.Commerce.price()
      :id -> Enum.random(1..100_000)
      :integer -> Enum.random(1..100_000)
      :map -> %{}
      :naive_datetime -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
      :naive_datetime_usec -> Faker.DateTime.between(~N[2000-01-01 00:00:00.000000Z], NaiveDateTime.utc_now())
      :string -> Faker.Company.bullshit() <> " " <> Faker.Commerce.product_name()
      :time -> nil
      :time_usec -> nil
      :utc_datetime -> Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())
      :utc_datetime_usec -> Faker.DateTime.between(~U[2000-01-01 00:00:00.000000Z], DateTime.utc_now())
      {:array, type} -> [fake(type, validation, config)]
      binary_id when binary_id in [:binary_id, Ecto.UUID] -> UUID.uuid4()
      other -> other_fake(other, config)
    end
  end

  defp other_fake(enum, config) when enum in [:enum, Ecto.Enum] do
    values = Keyword.fetch!(config, :values)
    Enum.random(values)
  end

  defp other_fake({:embed, %Ecto.Embedded{cardinality: :one}}, _config) do
    nil
  end
end
