defmodule Cqrs.DispatchContext do
  # TODO: Document :cqrs_tools, :context_shipper
  alias Cqrs.Message.Option
  alias Cqrs.DispatchContext.Shipper

  @type t :: %__MODULE__{message_type: atom(), message: struct(), errors: list()}
  @type command_context :: %__MODULE__{message_type: :command, message: struct(), errors: list()}
  @type query_context :: %__MODULE__{message_type: :query, message: struct(), errors: list()}

  defstruct [
    :message,
    :message_module,
    :discarded_data,
    :message_type,
    :created_at,
    :async,
    :user,
    :last_pipeline_step,
    private: %{},
    opts: [],
    message_opts: [],
    errors: [],
    pipeline: []
  ]

  @type context :: __MODULE__.t()

  @spec new(message :: struct(), map(), keyword) :: {:error, context} | {:ok, context}
  def new(%{__struct__: message_module} = message, discarded_data, opts) do
    {async, opts} = Keyword.pop(opts, :async, false)

    read_opts(%__MODULE__{
      opts: opts,
      async: async,
      message: message,
      message_module: message_module,
      discarded_data: discarded_data,
      created_at: DateTime.utc_now(),
      last_pipeline_step: :read_opts,
      message_type: message_module.__message_type__()
    })
  end

  defp read_opts(%{message_module: message_module, opts: opts} = base_context) do
    context =
      case Option.parse_message_opts(message_module, opts) do
        {:ok, message_opts, opts} -> %{base_context | opts: opts, message_opts: message_opts}
        {:error, error} -> %{base_context | errors: [error]}
      end

    case context do
      %{errors: []} = context ->
        {:ok, put_pipeline(context, :read_opts, :ok)}

      %{errors: errors} = context ->
        {:error, put_pipeline(context, :read_opts, {:error, errors})}
    end
  end

  @spec async?(context) :: boolean()
  def async?(%__MODULE__{async: async}), do: async

  @spec options(context) :: keyword()
  def options(%__MODULE__{opts: opts}), do: opts

  @spec get_option(context, atom, any | nil) :: any | nil
  def get_option(%__MODULE__{opts: opts}, key, default \\ nil) when is_atom(key), do: Keyword.get(opts, key, default)

  @spec user(context) :: map() | nil
  def user(%__MODULE__{user: user}), do: user

  @spec errors(context) :: map()
  def errors(%__MODULE__{errors: errors} = context) do
    Enum.reduce(errors, %{}, fn
      map, acc when is_map(map) -> Map.merge(acc, map)
      list, acc when is_list(list) -> acc ++ errors(%{context | errors: list})
      atom, acc when is_atom(atom) -> Map.update(acc, :generic, [atom], fn errors -> [atom | errors] end)
      string, acc when is_binary(string) -> Map.update(acc, :generic, [string], fn errors -> [string | errors] end)
    end)
  end

  @spec put_error(context, any) :: context
  def put_error(%__MODULE__{errors: errors} = context, error),
    do: %{context | errors: errors ++ List.wrap(error)}

  @spec put_private(context, atom, any) :: context
  def put_private(%__MODULE__{private: private} = context, key, value) when is_atom(key),
    do: %{context | private: Map.put(private, key, value)}

  @spec get_private(context) :: map()
  def get_private(%__MODULE__{private: private}), do: private

  @spec get_private(context, atom, any | nil) :: any | nil
  def get_private(%__MODULE__{private: private}, key, default \\ nil),
    do: Map.get(private, key, default)

  @spec put_pipeline(context, atom, any) :: context
  def put_pipeline(%__MODULE__{pipeline: pipeline} = context, key, value) when is_atom(key),
    do: %{context | last_pipeline_step: key, pipeline: pipeline ++ [{key, value}]}

  @spec get_pipeline(context, atom) :: any | nil
  def get_pipeline(%__MODULE__{pipeline: pipeline}, key) do
    pipeline
    |> Enum.into(%{})
    |> Map.get(key)
  end

  @spec get_last_pipeline(Cqrs.DispatchContext.t()) :: any | nil
  def get_last_pipeline(%__MODULE__{last_pipeline_step: step} = context),
    do: get_pipeline(context, step)

  def ship(%__MODULE__{} = context),
    do: Shipper.ship(context)
end
