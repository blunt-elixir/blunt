defmodule Blunt.QueryPipeline do
  @type opts :: keyword()
  @type filter_list :: keyword()
  @type query :: Ecto.Query.t() | any()
  @type context :: Blunt.DispatchContext.query_context()

  @callback create_query(filter_list(), context()) :: query()
  @callback handle_dispatch(query(), context(), opts()) :: any()

  defmacro __using__(_opts) do
    quote do
      import Ecto.Query
      use Blunt.Message.Compilation

      @behaviour Blunt.QueryPipeline
    end
  end
end
