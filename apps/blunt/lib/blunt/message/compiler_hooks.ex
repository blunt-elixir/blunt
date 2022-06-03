defmodule Blunt.Message.CompilerHooks do
  require Logger

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {manual_config, opts} = Keyword.pop(opts, :config, [])

      @manual_config manual_config
      @message_type Keyword.get(opts, :message_type)

      @before_compile Blunt.Message.CompilerHooks
    end
  end

  defmacro __before_compile__(%{module: module} = env) do
    message_type = Module.get_attribute(module, :message_type)
    manual_config = Module.get_attribute(module, :manual_config)

    run_compile_hooks(message_type, manual_config, env)
  end

  defp run_compile_hooks(nil, _manual_config, _env), do: nil

  defp run_compile_hooks(message_type, manual_config, env) do
    compiler_hooks =
      :blunt
      |> Application.get_all_env()
      |> Keyword.merge(manual_config)
      |> Keyword.get(:compiler_hooks, [])
      |> Keyword.get(message_type, [])

    case compiler_hooks do
      hooks when is_list(hooks) ->
        Enum.map(hooks, &run_compile_hook(&1, env))

      hook ->
        run_compile_hook(hook, env)
    end
  end

  defp run_compile_hook({module, function}, env) do
    Code.ensure_compiled!(module)

    case function_exported?(module, function, 1) do
      true -> apply(module, function, [env])
      false -> Logger.warn("Compiler hook #{inspect(module)}.#{function}/1 not found")
    end
  end

  defp run_compile_hook(_hook, _env), do: nil
end
