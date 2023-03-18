defmodule Blunt.Dialect do
  alias Blunt.Behaviour
  @callback setup(opts :: list({atom(), any()})) :: t()

  @type t :: %__MODULE__{
          dispatch_strategy: module(),
          pipeline_resolver: module() | nil,
          opts: list({atom, any})
        }

  @enforce_keys [:dispatch_strategy]
  defstruct [
    :dispatch_strategy,
    :pipeline_resolver,
    opts: []
  ]

  def configured_dialect! do
    {module, args} =
      case Application.get_env(:blunt, :dialect) do
        nil ->
          {Blunt.Dialect.StockDialect, [[]]}

        module when is_atom(module) ->
          {module, [[]]}

        {module, opts} when is_atom(module) and is_list(opts) ->
          {module, opts}
      end

    Behaviour.validate!(module, __MODULE__)
    apply(module, :setup, args)
  end
end
