import Config

config :blunt,
  context_shipper: nil,
  log_when_compiling: false,
  dispatch_return: :response,
  create_jason_encoders: false,
  documentation_output: false,
  dispatch_strategy: Blunt.DispatchStrategy.Default,
  pipeline_resolver: Blunt.DispatchStrategy.PipelineResolver.Default,
  dispatch_context_configuration: Blunt.DispatchContext.DefaultConfiguration
