defmodule Cqrs.QueryPipeline do
  @type opts :: keyword()
  @type filter_list :: keyword()
  @type query :: Ecto.Query.t() | any()
  @type context :: Cqrs.DispatchContext.query_context()

  @callback create_query(filter_list(), context()) :: query()
  @callback handle_dispatch(query(), context(), opts()) :: any()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Query

      @behaviour Cqrs.QueryPipeline
    end
  end
end
