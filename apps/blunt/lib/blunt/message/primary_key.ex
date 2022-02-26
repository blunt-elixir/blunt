defmodule Blunt.Message.PrimaryKey do
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

  def generate(%{module: module}) do
    pk_type = Module.get_attribute(module, :primary_key_type)

    unless pk_type == false do
      {name, type, opts} = pk_type

      opts =
        opts
        |> Keyword.put(:required, true)
        |> Keyword.put(:primary_key, true)

      Module.put_attribute(module, :schema_fields, {name, type, opts})
    end
  end
end
