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
    :id,
    :message,
    :metadata,
    :message_module,
    :discarded_data,
    :message_type,
    :created_at,
    :async,
    :user,
    :pid,
    :last_pipeline_step,
    user_supplied_fields: [],
    private: %{},
    opts: [],
    errors: [],
    return: :response,
    pipeline: []
  ]

  @type context :: __MODULE__.t()

  @spec new(message :: struct(), keyword) :: {:error, t} | {:ok, t}
  def new(%{__struct__: message_module} = message, opts) do
    message_type = Metadata.message_type(message_module)

    {discarded_data, message} = Map.get_and_update(message, :discarded_data, fn data -> {data, %{}} end)

    context = %__MODULE__{
      id: UUID.uuid4(),
      opts: opts,
      message: message,
      message_type: message_type,
      message_module: message_module,
      discarded_data: discarded_data,
      created_at: DateTime.utc_now(),
      pid: self()
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

    return = Keyword.get(opts, :return, :response)

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

  @spec discarded_data(t) :: map()
  def discarded_data(%{discarded_data: data}), do: data

  @spec async?(t) :: boolean()
  def async?(%__MODULE__{async: async}), do: async

  @spec get_message(t()) :: struct() | any()
  def get_message(%__MODULE__{message: message}), do: message

  @spec get_message_module(t()) :: atom()
  def get_message_module(%__MODULE__{message_module: message_module}), do: message_module

  @spec options(t) :: keyword()
  def options(%__MODULE__{opts: opts}), do: opts

  @spec options_map(t) :: map()
  def options_map(%__MODULE__{opts: opts}), do: Enum.into(opts, %{})

  @spec put_option(t, atom, any) :: context
  def put_option(%__MODULE__{opts: opts} = context, key, value) do
    %{context | opts: Keyword.put(opts, key, value)}
  end

  @spec get_option(t, atom, any | nil) :: any | nil
  def get_option(%__MODULE__{opts: opts}, key, default \\ nil) when is_atom(key), do: Keyword.get(opts, key, default)

  @spec get_return(t) :: atom()
  def get_return(%__MODULE__{return: return}), do: return

  @spec user(t) :: map() | nil
  def user(%__MODULE__{user: user}), do: user

  @spec put_user(t, any()) :: t()
  def put_user(%__MODULE__{} = context, user), do: %{context | user: user}

  @spec errors(t) :: map() | atom() | String.t()
  def errors(%__MODULE__{errors: [error]}), do: error

  def errors(%__MODULE__{errors: errors} = context) do
    Enum.reduce(errors, %{}, fn
      map, acc when is_map(map) -> Map.merge(acc, map)
      list, acc when is_list(list) -> acc ++ errors(%{context | errors: list})
      atom, acc when is_atom(atom) -> Map.update(acc, :generic, [atom], fn errors -> [atom | errors] end)
      string, acc when is_binary(string) -> Map.update(acc, :generic, [string], fn errors -> [string | errors] end)
    end)
  end

  @spec put_error(t, any) :: t
  def put_error(%__MODULE__{errors: errors} = context, error),
    do: %{context | errors: errors ++ List.wrap(error)}

  @spec internal_field(t, atom, any) :: t
  def internal_field(%{message: message} = context, field_name, value) do
    %{context | message: Map.put(message, field_name, value)}
  end

  @spec internal_field_new(t, atom, any) :: t
  def internal_field_new(%{message: message} = context, field_name, value) do
    case Map.get(message, field_name) do
      nil -> internal_field(context, field_name, value)
      _ -> context
    end
  end

  @spec internal_fields(t, map) :: t
  def internal_fields(%{message: message} = context, values) do
    %{context | message: Map.merge(message, values)}
  end

  @spec put_private(t, atom, any) :: t
  def put_private(%__MODULE__{private: private} = context, key, value) when is_atom(key),
    do: %{context | private: Map.put(private, key, value)}

  @spec put_private(t, struct() | map() | list()) :: t

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

  @spec get_private({:ok, t} | t) :: map()
  def get_private({:ok, %__MODULE__{private: private}}), do: private
  def get_private(%__MODULE__{private: private}), do: private

  @spec get_private({:ok, t} | t, atom, any | nil) :: any | nil
  def get_private(context, key, default \\ nil)

  def get_private({:ok, %__MODULE__{private: private}}, key, default),
    do: Map.get(private, key, default)

  def get_private(%__MODULE__{private: private}, key, default),
    do: Map.get(private, key, default)

  @spec put_pipeline(t, atom, any) :: t
  def put_pipeline(%__MODULE__{pipeline: pipeline} = context, key, value) when is_atom(key),
    do: %{context | last_pipeline_step: key, pipeline: pipeline ++ [{key, value}]}

  @spec get_pipeline(t) :: map()
  def get_pipeline(%__MODULE__{pipeline: pipeline}) do
    Enum.into(pipeline, %{})
  end

  @spec get_pipeline(t, atom) :: any | nil
  def get_pipeline(%__MODULE__{} = context, key) do
    context
    |> get_pipeline()
    |> Map.get(key)
  end

  @spec get_last_pipeline(t) :: any | nil
  def get_last_pipeline(%__MODULE__{last_pipeline_step: step} = context),
    do: get_pipeline(context, step)

  @spec user_supplied_fields(t) :: map()
  def user_supplied_fields(%{user_supplied_fields: user_supplied_fields}), do: user_supplied_fields

  @spec take_user_supplied_data(t) :: map()
  def take_user_supplied_data(%{message: nil}), do: %{}

  def take_user_supplied_data(%{message: command, user_supplied_fields: user_supplied_fields}) do
    command
    |> Map.from_struct()
    |> Map.take(user_supplied_fields)
  end

  @spec has_user_supplied_field?(t, atom()) :: boolean()
  def has_user_supplied_field?(%{user_supplied_fields: user_supplied_fields}, field) do
    Enum.member?(user_supplied_fields, field)
  end

  @spec get_metadata(t, atom, any) :: any | nil
  def get_metadata(%{metadata: metadata}, key, default \\ nil),
    do: Keyword.get(metadata, key, default)

  defdelegate format_errors(changeset), to: Blunt.Message.Changeset

  def field_names(%__MODULE__{message_module: module}), do: Metadata.field_names(module)
  def public_field_names(%__MODULE__{message_module: module}), do: Metadata.field_names(module, :public)
end
