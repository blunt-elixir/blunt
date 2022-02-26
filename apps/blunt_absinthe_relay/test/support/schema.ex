defmodule Blunt.Absinthe.Relay.Test.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types Blunt.Absinthe.Relay.Test.SchemaTypes

  query do
    import_fields :person_queries
  end
end
