defmodule Blunt.Absinthe.Field do
  @moduledoc false
  alias Blunt.Message.Metadata
  alias Blunt.DispatchContext, as: Context
  alias Blunt.Absinthe.{AbsintheErrors, Args, Field, Log, Middleware}
  alias Blunt.Absinthe.DispatchContext.Configuration, as: DispatchContextConfiguration

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

    args = args(operation, message_module, opts)
    description = description(message_module)

    {before_resolve, after_resolve} = middleware(opts)
    {configured_before_resolve, configured_after_resolve} = configured_middleware()

    Blunt.Message.Compilation.log(message_module, "regenerated #{operation} #{field_name}")

    quote do
      unquote_splicing(args)
      description(unquote(description))

      middleware(unquote(__MODULE__).prepare_context(unquote(message_module)))
      middleware(unquote(before_resolve))
      middleware(unquote(configured_before_resolve))

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

      middleware(unquote(after_resolve))
      middleware(unquote(configured_after_resolve))
    end
  end

  def prepare_context(message_module) do
    fn %{context: context} = resolution, _config ->
      blunt = %{absinthe_pid: self(), message_module: message_module}
      context = Map.put(context, :blunt, blunt)
      %{resolution | context: context}
    end
  end

  @type middlware_function :: (resolution(), keyword() -> resolution())
  @spec middleware(keyword) :: {middlware_function, middlware_function}
  def middleware(opts), do: Middleware.middleware(opts)
  def configured_middleware, do: Middleware.configured()

  @spec args(atom(), message_module, keyword) :: list
  def args(:absinthe_mutation, message_module, opts) do
    input_object = Keyword.get(opts, :input_object, false)
    input_object? = Keyword.get(opts, :input_object?, false)

    case input_object || input_object? do
      true ->
        field_name = :"#{Field.name(message_module, opts)}_input"
        [quote(do: arg(:input, unquote(field_name)))]

      false ->
        Args.from_message_fields(message_module, opts)
    end
  end

  def args(_operation, message_module, opts),
    do: Args.from_message_fields(message_module, opts)

  def description(message_module),
    do: message_module.__doc__(:short)

  @type resolution :: Absinthe.Resolution.t()
  @spec dispatch_and_resolve(atom, atom, keyword, map, map, any) :: {:error, list} | {:ok, any}
  def dispatch_and_resolve(operation, message_module, query_opts, parent, args, resolution) do
    context_configuration = DispatchContextConfiguration.configure(message_module, resolution)

    args = Map.get(args, :input, args)

    opts =
      query_opts
      |> put_dispatch_opts(operation, args)
      |> Keyword.merge(context_configuration)

    results =
      args
      |> Args.resolve_message_input({message_module, parent, query_opts})
      |> create_message(message_module)
      |> message_module.dispatch(opts)

    :ok = Log.dump()

    case results do
      {:error, %Context{} = context} ->
        {:error, AbsintheErrors.from_dispatch_context(context)}

      {:error, errors} when is_map(errors) ->
        {:error, AbsintheErrors.format(errors)}

      {:ok, %Context{} = context} ->
        {:ok, Context.get_last_pipeline(context)}

      other ->
        other
    end
  end

  defp create_message(input_data, message_module) do
    case Metadata.fields(message_module) do
      [] -> message_module.new()
      _fields -> message_module.new(input_data)
    end
  end

  def put_dispatch_opts(opts, operation, args) do
    user_supplied_fields = args |> Map.keys() |> Enum.sort()

    opts
    |> Keyword.put(:ship, false)
    |> Keyword.put(:return, :context)
    |> Keyword.put(operation, true)
    |> Keyword.put(:user_supplied_fields, user_supplied_fields)
  end
end
