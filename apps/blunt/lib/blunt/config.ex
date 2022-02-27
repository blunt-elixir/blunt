defmodule Blunt.Config do
  # TODO: Document configuration

  defmodule ConfigError do
    defexception [:message]
  end

  alias Blunt.{Behaviour, DispatchContext, DispatchContext.Shipper, DispatchStrategy, DispatchStrategy.PipelineResolver}

  def log_when_compiling?,
    do: get(:log_when_compiling, false)

  def create_jason_encoders?,
    do: get(:create_jason_encoders, true)

  @doc false
  def create_jason_encoders?(opts) do
    explicit = Keyword.get(opts, :create_jason_encoders?, true)
    configured = get(:create_jason_encoders, true)

    explicit && configured
  end

  @doc false
  def dispatch_return do
    valid_values = [:context, :response]
    value = get(:dispatch_return, :response)

    unless Enum.member?(valid_values, value) do
      raise ConfigError,
        message:
          "Invalid :blunt, :dispatch_return value: `#{value}`. Value must be one of the following: #{inspect(valid_values)}"
    end

    value
  end

  @doc false
  def documentation_output,
    do: get(:documentation_output, false)

  @doc false
  def dispatch_context_configuration do
    :dispatch_context_configuration
    |> get(DispatchContext.DefaultConfiguration)
    |> Behaviour.validate!(DispatchContext.Configuration)
  end

  @doc false
  def dispatch_strategy! do
    :dispatch_strategy
    |> get(DispatchStrategy.Default)
    |> Behaviour.validate!(DispatchStrategy)
  end

  @doc false
  def pipeline_resolver! do
    :pipeline_resolver
    |> get(PipelineResolver.Default)
    |> Behaviour.validate!(PipelineResolver)
  end

  @doc false
  def context_shipper! do
    case get(:context_shipper) do
      nil -> nil
      shipper -> Behaviour.validate!(shipper, Shipper)
    end
  end

  defp get(key, default \\ nil), do: Application.get_env(:blunt, key, default)
end
