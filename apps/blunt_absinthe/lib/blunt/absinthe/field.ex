defmodule Blunt.Absinthe.Field do
  @moduledoc false
  alias Blunt.DispatchContext, as: Context
  alias Blunt.Absinthe.{AbsintheErrors, Args, Field, Log, Middleware}

  @type message_module :: atom()

  @spec name(atom, keyword) :: atom()
  def name(module, opts) do
    [name | _] =
      module
      |> Module.split()
      |> Enum.reverse()

    default_function_name =
      name
      |> to_string
      |> Macro.underscore()
      |> String.to_atom()

    Keyword.get(opts, :as, default_function_name)
  end

  @spec generate_body(atom(), atom, message_module, keyword) :: {:__block__, [], [...]}
  def generate_body(operation, field_name, message_module, opts) do
    opts =
      opts
      |> Keyword.put(:operation, operation)
      |> Keyword.put(:field_name, field_name)

    args = args(message_module, opts)
    description = description(message_module)
    {before_resolve, after_resolve} = middleware(opts)

    Blunt.Message.Compilation.log(message_module, "regenerated #{operation} #{field_name}")

    quote do
      unquote_splicing(args)
      description unquote(description)
      middleware unquote(before_resolve)

      resolve(fn parent, args, resolution ->
        Field.dispatch_and_resolve(
          unquote(operation),
          unquote(message_module),
          unquote(opts),
          parent,
          args,
          resolution
        )
      end)

      middleware unquote(after_resolve)
    end
  end

  @type middlware_function :: (resolution(), keyword() -> resolution())
  @spec middleware(keyword) :: {middlware_function, middlware_function}
  def middleware(opts), do: Middleware.middleware(opts)

  @spec args(message_module, keyword) :: list
  def args(message_module, opts),
    do: Args.from_message_fields(message_module, opts)

  def description(message_module),
    do: message_module.__doc__(:short)

  @type resolution :: Absinthe.Resolution.t()
  @spec dispatch_and_resolve(atom, atom, keyword, map, map, any) :: {:error, list} | {:ok, any}
  def dispatch_and_resolve(operation, message_module, query_opts, parent, args, _resolution) do
    opts = put_dispatch_opts(query_opts, operation, args)

    results =
      args
      |> Args.resolve_message_input({message_module, parent, query_opts})
      |> message_module.new()
      |> message_module.dispatch(opts)

    :ok = Log.dump()

    case results do
      {:error, %Context{} = context} ->
        return_value = {:error, AbsintheErrors.from_dispatch_context(context)}

        context
        |> Context.put_pipeline(:absinthe_resolve, return_value)
        |> Context.Shipper.ship()

        return_value

      {:ok, %Context{} = context} ->
        return_value = {:ok, Context.get_last_pipeline(context)}

        context
        |> Context.put_pipeline(:absinthe_resolve, return_value)
        |> Context.Shipper.ship()

        return_value
    end
  end

  def put_dispatch_opts(opts, operation, args) do
    opts
    |> Keyword.put(:return, :context)
    |> Keyword.put(operation, true)
    |> Keyword.put(:user_supplied_fields, Map.keys(args))
  end
end
