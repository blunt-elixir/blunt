defmodule Cqrs.Message.PrimaryKey do
  @moduledoc false
  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      primary_key =
        case Keyword.get(opts, :primary_key, false) do
          {name, type, config} -> {name, type, config}
          value -> value
        end

      Module.put_attribute(__MODULE__, :primary_key_type, primary_key)
    end
  end

  defmacro generate do
    quote do
      unless @primary_key_type == false do
        {name, type, opts} = @primary_key_type

        opts =
          opts
          |> Keyword.put(:required, true)
          |> Keyword.put(:primary_key, true)

        @schema_fields {name, type, opts}
      end
    end
  end
end
