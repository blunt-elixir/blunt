defmodule Cqrs.Message.Options do
  @moduledoc false

  require Logger

  alias Cqrs.Config

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
        |> Enum.map(fn {name, type, config} -> {name, type, Keyword.drop(config, [:desc, :notes])} end)

      @metadata options: options
    end
  end

  def return_option do
    configured_value = Config.dispatch_return()

    desc = "Determines what will be returned from a call to `dispatch`"

    notes = ~s[
      `:context` - returns the `DispatchContext` from dispatch.

      `:response` - returns the value returned from dispatch.
    ]

    {:return, :enum,
     [values: [:context, :response], default: configured_value, required: false, desc: desc, notes: notes]}
  end

  def query_return_option do
    configured_value = Config.dispatch_return()

    desc = "Determines what will be returned from a call to `dispatch`"

    notes = ~s[
      `:context` - returns the `DispatchContext` from dispatch.

      `:response` - returns the value returned from dispatch.

      `:query` - returns the fully constructed query without executing it.

      `:query_context` -  returns the `DispatchContext` from dispatch without executing the query.
    ]

    {:return, :enum,
     [
       values: [:context, :response, :query, :query_context],
       default: configured_value,
       required: false,
       desc: desc,
       notes: notes
     ]}
  end
end
