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

  def generate(%{module: module}) do
    if Module.delete_attribute(module, :versioned?) do
      version = Module.delete_attribute(module, :version) || 1
      Module.put_attribute(module, :metadata, version: version)
      Module.put_attribute(module, :schema_fields, {:version, :decimal, default: version, required: false})
    end
  end
end
