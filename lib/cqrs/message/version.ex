defmodule Cqrs.Message.Version do
  @moduledoc false

  defmacro register(opts) do
    quote bind_quoted: [opts: opts] do
      if Keyword.get(opts, :versioned?, false) do
        Module.put_attribute(__MODULE__, :versioned?, true)
        Module.register_attribute(__MODULE__, :version, [])
      end
    end
  end

  defmacro generate do
    quote do
      if Module.delete_attribute(__MODULE__, :versioned?) do
        version = Module.delete_attribute(__MODULE__, :version) || 1
        @metadata version: version
        @schema_fields {:version, :decimal, default: version, required: false}
      end
    end
  end
end
