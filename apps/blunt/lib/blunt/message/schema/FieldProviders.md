# Field Providers

In Blunt, you can define field types based on your domain needs. This might help describe your domain better than generic data types.

To achieve this, we need to tell Blunt where these fields are defined. We need to implement the `Blunt.Message.Schema.FieldProvider` behaviour and configure the `schema_field_providers` Blunt setting.

The `schema_field_providers` setting can accept one or more `FieldProviders`

## Example

```elixir
defmodule EmailFieldProvider do
  @behaviour Blunt.Message.Schema.FieldProvider

  alias Ecto.Changeset
  alias Blunt.Message.Schema

  @impl true
  # This callback is what allows us to register a custom field type.
  # You can optionally register a validation to go along with the type.
  def ecto_field(module, {field_name, :email, opts}) do
    quote bind_quoted: [module: module, field_name: field_name, opts: opts] do
      Schema.put_field_validation(module, field_name, :email)
      Ecto.Schema.field(field_name, :string, opts)
    end
  end

  @impl true
  # If you registered a validation for your field, you must handle it
  def validate_changeset(:email, field_name, changeset, _module) do
    Changeset.validate_format(changeset, field_name, ~r/@/)
  end

  @impl true
  # `Blunt.Testing.Factories` knows to use field providers for fake data
  def fake(:email, _validation, _field_config) do
    "fake_hombre@example.com"
  end
end
```

### Usage

in `config.exs`

```elixir
config :blunt, schema_field_providers: [
    EmailFieldProvider
  ]
```

In a message

```elixir 
defmodule CustomMessage do
  use Blunt.Command

  field :email_address, :email, required: true
end
```
