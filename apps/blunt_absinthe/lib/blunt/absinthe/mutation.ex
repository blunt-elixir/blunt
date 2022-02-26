defmodule Blunt.Absinthe.Mutation do
  @moduledoc false

  alias Blunt.Absinthe.Field

  @spec generate_field(atom, any, keyword) :: {:field, [], [...]}
  def generate_field(command_module, return_type, opts) do
    field_name = Field.name(command_module, opts)
    body = Field.generate_body(:absinthe_mutation, field_name, command_module, opts)

    quote do
      field unquote(field_name), unquote(return_type) do
        unquote(body)
      end
    end
  end
end
