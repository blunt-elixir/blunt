defmodule Blunt.Message.Options do
  @moduledoc false

  require Logger

  alias Blunt.Config

  defmacro register do
    quote do
      Module.register_attribute(__MODULE__, :options, accumulate: true)
    end
  end

  def record(name, type, opts) do
    quote bind_quoted: [name: name, type: type, opts: opts] do
      opts =
        opts
        |> Keyword.put_new(:default, nil)
        |> Keyword.put_new(:required, false)

      @options {name, type, opts}
    end
  end

  defmacro generate do
    quote do
      options =
        __MODULE__
        |> Module.delete_attribute(:options)
        |> Enum.map(fn {name, type, config} -> {name, type, Keyword.drop(config, [:desc])} end)

      @metadata options: options
    end
  end

  def return_option do
    configured_value = Config.dispatch_return()

    desc = "Determines the value to be returned from `dispatch/2`. "
    desc = desc <> "If the value is `:context` the dispatch context will be returned. "
    desc = desc <> "If the value is`:response` the value will be returned. "

    {:return, :enum, [values: [:context, :response], default: configured_value, required: false, desc: desc]}
  end

  def query_return_option do
    configured_value = Config.dispatch_return()

    desc = "Determines the value to be returned from `dispatch/2`. "
    desc = desc <> "If the value is `:context` the dispatch context will be returned. "
    desc = desc <> "If the value is`:response` the value will be returned. "
    desc = desc <> "If the value is`:query` the query will be returned without executing it. "
    desc = desc <> "If the value is`:query_context` the dispatch context will be returned without executing the query. "

    {:return, :enum,
     [
       values: [:context, :response, :query, :query_context],
       default: configured_value,
       required: false,
       desc: desc
     ]}
  end
end
