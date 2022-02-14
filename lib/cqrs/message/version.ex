defmodule Cqrs.Message.Version do
  @moduledoc false

  def register(module, opts) do
    if Keyword.get(opts, :versioned?, false) do
      Module.put_attribute(module, :versioned?, true)
      Module.register_attribute(module, :version, [])
    end
  end

  def generate(module) do
    if Module.delete_attribute(module, :versioned?) do
      version = Module.delete_attribute(module, :version) || 1

      data =
        quote do
          @metadata version: unquote(version)
          @schema_fields {:version, :decimal, default: unquote(version), required: false}
        end

      Module.eval_quoted(module, data)
    end
  end
end
