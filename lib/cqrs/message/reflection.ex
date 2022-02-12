defmodule Cqrs.Message.Reflection do
  @moduledoc false

  defmacro generate do
    quote generated: true do
      def __message_type__, do: @message_type
      def __schema_fields__, do: @schema_fields
      def __primary_key__, do: @primary_key_type

      def __required_fields__ do
        case __primary_key__() do
          {name, _type, _config} -> [name | @required_fields]
          _ -> @required_fields
        end
      end
    end
  end
end
