defmodule Blunt.Ddd.Config do
  def domain_event_compile_hook(env) do
    case get(:domain_event_compile_hook) do
      hooks when is_list(hooks) ->
        Enum.map(hooks, &run_domain_event_compile_hook(&1, env))

      hook ->
        run_domain_event_compile_hook(hook, env)
    end
  end

  defp run_domain_event_compile_hook({module, function}, env) do
    if function_exported?(module, function, 1) do
      apply(module, function, [env])
    end
  end

  defp run_domain_event_compile_hook(_hook, _env), do: nil

  defp get(key, default \\ nil), do: Application.get_env(:blunt_ddd, key, default)
end
