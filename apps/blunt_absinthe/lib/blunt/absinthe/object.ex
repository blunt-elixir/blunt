defmodule Blunt.Absinthe.Object do
  @moduledoc false

  alias Blunt.Absinthe.Args

  def generate_object(message_module, object_name, opts) do
    opts =
      opts
      |> Keyword.put(:type, :fields)
      |> Keyword.put(:operation, :derive_object)
      |> Keyword.put(:field_name, object_name)

    fields = Args.from_message_fields(message_module, opts)

    case Keyword.get(opts, :input_object, false) do
      true ->
        quote do
          input_object unquote(object_name) do
            (unquote_splicing(fields))
          end
        end

      false ->
        quote do
          object unquote(object_name) do
            (unquote_splicing(fields))
          end
        end
    end
  end
end
