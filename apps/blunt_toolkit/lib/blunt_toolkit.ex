defmodule CqrsToolkit do
  import Ratatouille.Constants, only: [key: 1]

  def run_tui(app) do
    case Mix.Project.config()[:app] do
      nil ->
        raise "not in a mix project"

      app_name ->
        Logger.configure(level: :warning)
        Mix.Task.run("app.start", ["--no-start"])

        with {:ok, _} <- Application.ensure_all_started(app_name) do
          Ratatouille.run(app, quit_events: [{:key, key(:ctrl_c)}])
        end
    end
  end
end
