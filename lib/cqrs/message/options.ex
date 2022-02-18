defmodule Cqrs.Message.Options do
  @moduledoc false

  defmodule Error do
    defexception [:message]
  end

  require Logger

  alias Cqrs.Config
  alias Cqrs.Message.Options

  defmacro register do
    quote do
      Module.register_attribute(__MODULE__, :options, accumulate: true)
      @options Options.return_option()
    end
  end

  def record(name, type, opts) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
      opts =
        opts
        |> Keyword.put_new(:default, nil)
        |> Keyword.put_new(:required, false)
        |> Keyword.put(:type, type)

      @options {name, opts}
    end
  end

  defmacro generate do
    quote do
      @metadata options: Module.delete_attribute(__MODULE__, :options)
    end
  end

  def return_option do
    values = [:context, :response]

    value = Config.dispatch_return()

    unless value in values do
      raise Error,
        message:
          "Invalid :cqrs, :dispatch_return value: `#{value}`. Value must be one of the following: #{inspect(values)}"
    end

    {:return, [type: :enum, values: values, default: value, required: true]}
  end
end
