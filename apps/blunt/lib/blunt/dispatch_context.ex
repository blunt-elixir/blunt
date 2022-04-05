defmodule Blunt.DispatchContext do
  alias Blunt.Config
  alias Blunt.Message.{Metadata, Options}

  defmodule Error do
    defexception [:message]
  end

  @type t :: %__MODULE__{message_type: atom(), message: struct(), errors: list()}
  @type command_context :: %__MODULE__{message_type: :command, message: struct(), errors: list()}
  @type query_context :: %__MODULE__{message_type: :query, message: struct(), errors: list()}

  if Code.ensure_loaded?(Jason) && Config.create_jason_encoders?() do
    @derive Jason.Encoder
  end

  defstruct [
    :message,
    :metadata,
    :message_module,
    :discarded_data,
    :message_type,
    :created_at,
    :async,
    :user,
    :last_pipeline_step,
    user_supplied_fields: [],
    private: %{},
    opts: [],
    errors: [],
    return: :response,
    pipeline: []
  ]

  @type context :: __MODULE__.t()

  @spec new(message :: struct(), keyword) :: {:error, context} | {:ok, context}
  def new(%{__struct__: message_module} = message, opts) do
    message_type = Metadata.message_type(message_module)

    context = %__MODULE__{
      opts: opts,
      message: message,
      message_type: message_type,
      message_module: message_module,
      discarded_data: message.discarded_data,
      created_at: DateTime.utc_now()
    }

    context
    |> add_metadata()
    |> populate_from_opts()
    |> parse_message_opts()
  end

  def merge_private(%__MODULE__{message: message, private: private}) do
    Map.merge(message, private)
  end

  defp add_metadata(%{message_module: message_module} = context) do
    metadata = Metadata.get_all(message_module)
    %{context | metadata: metadata}
  end

  defp populate_from_opts(%{opts: opts} = base_context) do
    {user, opts} = Keyword.pop(opts, :user)
    {async, opts} = Keyword.pop(opts, :async, false)
    {user_supplied_fields, opts} = Keyword.pop(opts, :user_supplied_fields, [])
    {return, opts} = Keyword.pop(opts, :return, :response)

    %{
      base_context
      | user: user,
        opts: opts,
        async: async,
        return: return,
        last_pipeline_step: :read_opts,
        user_supplied_fields: user_supplied_fields
    }
  end

  defp parse_message_opts(%{message_module: message_module, opts: incoming_opts} = base_context) do
    context =
      case Options.Parser.parse_message_opts(message_module, incoming_opts) do
        {:ok, opts} -> %{base_context | opts: Keyword.merge(incoming_opts, opts)}
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

  @spec get_message(context()) :: struct() | any()
  def get_message(%__MODULE__{message: message}), do: message

  @spec options(context) :: keyword()
  def options(%__MODULE__{opts: opts}), do: opts

  @spec put_option(context, atom, any) :: context
  def put_option(%__MODULE__{opts: opts} = context, key, value) do
    %{context | opts: Keyword.put(opts, key, value)}
  end

  @spec get_option(context, atom, any | nil) :: any | nil
  def get_option(%__MODULE__{opts: opts}, key, default \\ nil) when is_atom(key), do: Keyword.get(opts, key, default)

  @spec get_return(context) :: atom()
  def get_return(%__MODULE__{return: return}), do: return

  @spec user(context) :: map() | nil
  def user(%__MODULE__{user: user}), do: user

  @spec put_user(context, any()) :: context()
  def put_user(%__MODULE__{} = context, user), do: %{context | user: user}

  @spec errors(context) :: map()
  def errors(%__MODULE__{errors: [error]}), do: error

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

  @spec internal_field(context, atom, any) :: context
  def internal_field(%{message: message} = context, field_name, value) do
    %{context | message: Map.put(message, field_name, value)}
  end

  @spec put_private(context, atom, any) :: context
  def put_private(%__MODULE__{private: private} = context, key, value) when is_atom(key),
    do: %{context | private: Map.put(private, key, value)}

  @spec put_private(context, struct() | map() | list()) :: context

  def put_private(%__MODULE__{} = context, list) when is_list(list) do
    unless Keyword.keyword?(list) do
      raise Error, message: "private values must be a struct, map, or keyword list"
    end

    put_private(context, Enum.into(list, %{}))
  end

  def put_private(%__MODULE__{} = context, map) when is_struct(map),
    do: put_private(context, Map.from_struct(map))

  def put_private(%__MODULE__{private: private} = context, map) when is_map(map),
    do: %{context | private: Map.merge(private, map)}

  @spec get_private({:ok, context} | context) :: map()
  def get_private({:ok, %__MODULE__{private: private}}), do: private
  def get_private(%__MODULE__{private: private}), do: private

  @spec get_private({:ok, context} | context, atom, any | nil) :: any | nil
  def get_private(context, key, default \\ nil)

  def get_private({:ok, %__MODULE__{private: private}}, key, default),
    do: Map.get(private, key, default)

  def get_private(%__MODULE__{private: private}, key, default),
    do: Map.get(private, key, default)

  @spec put_pipeline(context, atom, any) :: context
  def put_pipeline(%__MODULE__{pipeline: pipeline} = context, key, value) when is_atom(key),
    do: %{context | last_pipeline_step: key, pipeline: pipeline ++ [{key, value}]}

  @spec get_pipeline(context) :: map()
  def get_pipeline(%__MODULE__{pipeline: pipeline}) do
    Enum.into(pipeline, %{})
  end

  @spec get_pipeline(context, atom) :: any | nil
  def get_pipeline(%__MODULE__{} = context, key) do
    context
    |> get_pipeline()
    |> Map.get(key)
  end

  @spec get_last_pipeline(context) :: any | nil
  def get_last_pipeline(%__MODULE__{last_pipeline_step: step} = context),
    do: get_pipeline(context, step)

  @spec user_supplied_fields(context) :: map()
  def user_supplied_fields(%{user_supplied_fields: user_supplied_fields}), do: user_supplied_fields

  @spec take_user_supplied_data(context) :: map()
  def take_user_supplied_data(%{message: nil}), do: %{}

  def take_user_supplied_data(%{message: command, user_supplied_fields: user_supplied_fields}) do
    command
    |> Map.from_struct()
    |> Map.take(user_supplied_fields)
  end

  @spec get_metadata(context, atom, any) :: any | nil
  def get_metadata(%{metadata: metadata}, key, default \\ nil),
    do: Keyword.get(metadata, key, default)
end
