defmodule Blunt.Absinthe.Query do
  @moduledoc false

  alias Blunt.Absinthe.Field

  @spec generate_field(atom, any, keyword) :: {:field, [], [...]}
  def generate_field(query_module, return_type, opts) do
    field_name = Field.name(query_module, opts)
    body = Field.generate_body(:absinthe_query, field_name, query_module, opts)

    quote do
      field unquote(field_name), unquote(return_type) do
        unquote(body)
      end
    end
  end
end
