defmodule Cqrs.Message.Reflection do
  @moduledoc false

  defmacro generate do
    quote do
      def __message_type__, do: @message_type
      def __options__, do: @options
      def __schema_fields__, do: @schema_fields
    end
  end
end
