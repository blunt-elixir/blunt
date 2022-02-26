defmodule Blunt.Context do
  alias Blunt.Context
  alias Blunt.Context.Proxy

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      use Blunt.Message.Compilation

      Module.register_attribute(__MODULE__, :proxies, accumulate: true)
      Module.register_attribute(__MODULE__, :messages, accumulate: true, persist: true)

      @before_compile Blunt.Context
      @after_compile Blunt.Context

      import Blunt.Context, only: :macros
    end
  end

  defmacro command(message_module, opts \\ []) do
    quote bind_quoted: [message_module: message_module, opts: opts] do
      {function_name, _opts} = Proxy.function_name(message_module, opts)

      @messages {:command, message_module, function_name}
      @proxies {{:command, message_module, opts}, {__ENV__.file, __ENV__.line}}
    end
  end

  defmacro query(message_module, opts \\ []) do
    quote bind_quoted: [message_module: message_module, opts: opts] do
      {function_name, _opts} = Proxy.function_name(message_module, opts)

      @messages {:query, message_module, function_name}
      @proxies {{:query, message_module, opts}, {__ENV__.file, __ENV__.line}}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Enum.map(@proxies, fn {message_info, {file, line}} ->
        code = Proxy.generate(message_info)

        __ENV__
        |> Map.put(:file, file)
        |> Map.put(:line, line)
        |> Module.eval_quoted(code)
      end)
    end
  end

  defmacro __after_compile__(%{module: module}, _bytecode) do
    module
    |> Context.proxied_messages()
    |> Enum.each(&Proxy.validate!(&1, module))

    nil
  end

  @doc false
  def proxied_messages(bounded_context_module) do
    :attributes
    |> bounded_context_module.__info__()
    |> Keyword.get_values(:messages)
    |> List.flatten()
  end
end
