defmodule Blunt.Data.Factories.InputConfiguration do
  @callback configure(map()) :: map()

  def configure(input) do
    config = Application.get_env(:blunt, :factory_input_configuration, __MODULE__.Default)
    config.configure(input)
  end
end
