defmodule Blunt.Absinthe.Message do
  @moduledoc false

  alias Blunt.Absinthe.Error
  alias Blunt.Message.Metadata

  def validate!(:command, module) do
    error = "#{inspect(module)} is not a valid #{inspect(Blunt.Command)}"
    do_validate!(module, :command, error)
  end

  def validate!(:query, module) do
    error = "#{inspect(module)} is not a valid #{inspect(Blunt.Query)}"
    do_validate!(module, :query, error)
  end

  defp do_validate!(module, type, error) do
    case Code.ensure_compiled(module) do
      {:module, module} ->
        unless Metadata.is_message_type?(module, type) do
          raise Error, message: error
        end

      _ ->
        raise Error, message: error
    end
  end
end
