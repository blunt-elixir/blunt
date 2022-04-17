defmodule Blunt.Absinthe.Mutation do
  @moduledoc false

  alias Blunt.Absinthe.{Args, Field}

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

  def generate_input(command_module, opts) do
    field_name = :"#{Field.name(command_module, opts)}_input"

    opts =
      opts
      |> Keyword.put(:field_name, field_name)
      |> Keyword.put(:operation, :input_object)

    fields = Args.from_message_fields(command_module, Keyword.put(opts, :type, :fields))

    quote do
      input_object unquote(field_name) do
        (unquote_splicing(fields))
      end
    end
  end
end
