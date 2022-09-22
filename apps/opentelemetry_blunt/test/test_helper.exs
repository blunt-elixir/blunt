ExUnit.start()

defmodule TestHelpers do
  def remove_blunt_handlers() do
    Enum.each(:telemetry.list_handlers([:blunt]), fn handler ->
      :telemetry.detach(handler[:id])
    end)
  end
end
