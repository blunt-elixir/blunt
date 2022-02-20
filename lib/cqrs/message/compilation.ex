defmodule Cqrs.Message.Compilation do
  @moduledoc false
  require Logger

  alias Cqrs.Message.Compilation

  defmacro __using__(_opts) do
    quote do
      @after_compile Compilation
      @before_compile Compilation

      Module.register_attribute(__MODULE__, :compile_start, persist: true)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @compile_start DateTime.utc_now()
    end
  end

  defmacro __after_compile__(%{module: module}, _code) do
    compile_start = Compilation.compile_start(module)
    elapsed = DateTime.diff(DateTime.utc_now(), compile_start, :millisecond)

    Compilation.log(module, "compiled", elapsed)
  end

  def compile_start(message_module) do
    :attributes
    |> message_module.__info__()
    |> Keyword.get(:compile_start)
    |> hd()
  end

  def log(module, action, elapsed_milliseconds \\ nil) do
    cond do
      Cqrs.Config.log_when_compiling?() == true ->
        if elapsed_milliseconds,
          do: Logger.info("[cqrs_tools] #{action} #{inspect(module)} (#{elapsed_milliseconds} ms)"),
          else: Logger.info("[cqrs_tools] #{action} #{inspect(module)}")

        nil

      true ->
        nil
    end
  end
end
