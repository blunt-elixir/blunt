import Config

config :cqrs_tools,
  context_shipper: nil,
  dispatch_return: :response,
  create_jason_encoders: false,
  dispatch_strategy: Cqrs.DispatchStrategy.Default,
  pipeline_resolver: Cqrs.DispatchStrategy.PipelineResolver.Default
