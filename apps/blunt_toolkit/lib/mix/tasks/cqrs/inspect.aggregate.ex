defmodule Mix.Tasks.Blunt.Inspect.Aggregate do
  use Mix.Task

  def run(_args) do
    CqrsToolkit.run_tui(Blunt.Toolkit.AggregateInspector)
  end
end
