defmodule Cqrs.DispatchContext do
  # TODO: Document :cqrs_tools, :context_shipper
  alias Cqrs.Message.Option
  alias Cqrs.DispatchContext.Shipper

  @type t :: %__MODULE__{message_type: atom(), message: struct(), errors: list()}
  @type command_context :: %__MODULE__{message_type: :command, message: struct(), errors: list()}
  @type query_context :: %__MODULE__{message_type: :query, message: struct(), errors: list()}

  defstruct [
    :message,
    :discarded_data,
    :message_type,
    :created_at,
    :async,
    :user,
    :last_pipeline_step,
    private: %{},
    opts: [],
    errors: [],
    pipeline: []
  ]

  def new(%{__struct__: message_module} = message, discarded_data, opts) do
    {async, opts} = Keyword.pop(opts, :async, false)

    base_context = %__MODULE__{
      opts: opts,
      async: async,
      message: message,
      discarded_data: discarded_data,
      created_at: DateTime.utc_now(),
      last_pipeline_step: :read_opts,
      message_type: message_module.__message_type__()
    }

    context =
      case Option.parse_message_opts(message_module, opts) do
        {:ok, opts} -> %{base_context | opts: opts}
        {:error, error} -> %{base_context | errors: [error]}
      end

    case context do
      %{errors: []} = context ->
        {:ok, put_pipeline(context, :read_opts, :ok)}

      %{errors: errors} = context ->
        {:error, put_pipeline(context, :read_opts, errors)}
    end
  end

  def async?(%__MODULE__{async: async}), do: async

  def options(%__MODULE__{opts: opts}), do: opts
  def get_option(%__MODULE__{opts: opts}, key, default \\ nil) when is_atom(key), do: Keyword.get(opts, key, default)

  def user(%__MODULE__{user: user}), do: user

  def errors(%__MODULE__{errors: errors}),
    do: Enum.reduce(errors, %{}, &Map.merge(&2, &1))

  def put_error(%__MODULE__{errors: errors} = context, error),
    do: %{context | errors: errors ++ List.wrap(error)}

  def put_private(%__MODULE__{private: private} = context, key, value) when is_atom(key),
    do: %{context | private: Map.put(private, key, value)}

  def get_private(%__MODULE__{private: private}), do: private

  def get_private(%__MODULE__{private: private}, key, default \\ nil),
    do: Map.get(private, key, default)

  def put_pipeline(%__MODULE__{pipeline: pipeline} = context, key, value) when is_atom(key),
    do: %{context | last_pipeline_step: key, pipeline: pipeline ++ [{key, value}]}

  def get_pipeline(%__MODULE__{pipeline: pipeline}, key) do
    pipeline
    |> Enum.into(%{})
    |> Map.get(key)
  end

  def get_last_pipeline(%__MODULE__{last_pipeline_step: step} = context),
    do: get_pipeline(context, step)

  def ship(%__MODULE__{} = context),
    do: Shipper.ship(context)
end
