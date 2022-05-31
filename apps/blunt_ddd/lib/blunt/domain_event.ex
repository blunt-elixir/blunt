defmodule Blunt.DomainEvent do
  alias Blunt.Ddd.{Config, Constructor}

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(opts) do
    {derive_from, opts} = Keyword.pop(opts, :derive_from)

    quote bind_quoted: [derive_from: derive_from, opts: opts] do
      use Blunt.Message,
          [require_all_fields?: false]
          |> Keyword.merge(opts)
          |> Constructor.put_option()
          |> Keyword.put(:versioned?, true)
          |> Keyword.put(:message_type, :domain_event)

      unless is_nil(derive_from) do
        fields = Blunt.DomainEvent.__derive_from__(derive_from, opts)
        Module.eval_quoted(__MODULE__, fields)
      end

      @before_compile Blunt.DomainEvent
    end
  end

  @doc false
  def __derive_from__(command_module, opts) do
    quote bind_quoted: [command_module: command_module, opts: opts] do
      unless Blunt.Message.Metadata.is_command?(command_module) do
        raise Error, message: "derive_from requires a Blunt.Command. #{inspect(command_module)} is not one."
      else
        to_drop =
          opts
          |> Keyword.get(:drop, [])
          |> List.wrap()
          |> Kernel.++([:discarded_data])

        command_module
        |> Blunt.Message.Metadata.fields()
        |> Enum.reject(fn {name, _type, _opts} -> Enum.member?(to_drop, name) end)
        |> Enum.map(fn field ->
          @schema_fields field
        end)
      end
    end
  end

  defmacro __before_compile__(env) do
    user_defined_code = Config.domain_event_compile_hook(env)

    quote do
      unquote(user_defined_code)
      require Constructor
      Constructor.generate(return_type: :struct)
    end
  end
end
