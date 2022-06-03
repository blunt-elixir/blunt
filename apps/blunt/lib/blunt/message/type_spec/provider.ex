defmodule Blunt.Message.TypeSpec.Provider do
  @type field_definition :: {name :: atom(), type :: atom(), opts :: keyword()}
  @callback provide(field_definition()) :: {atom(), Macro.t()}

  require Logger

  alias Blunt.Config

  def provide({name, type, _opts} = field_definition) do
    case Config.type_spec_provider() do
      nil ->
        Logger.warn("unable to generate typespec for field #{name} [#{type}]")

      provider ->
        case provider.provide(field_definition) do
          nil ->
            Logger.warn("unable to generate typespec for field #{name} [#{type}]")

          type_spec ->
            type_spec
        end
    end
  end
end
