defmodule Blunt.Data.Factories.FakeProvider.Default do
  @behaviour Blunt.Data.Factories.FakeProvider

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
      binary_id when binary_id in [:binary_id, Ecto.UUID] -> Ecto.UUID.generate()
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
