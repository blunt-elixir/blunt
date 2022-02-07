defmodule Cqrs.Message.Field do
  @moduledoc false

  def record(name, type, opts \\ []) do
    quote do
      required = Keyword.get(unquote(opts), :required, @require_all_fields?)

      opts =
        [default: nil]
        |> Keyword.merge(unquote(opts))
        |> Keyword.put(:required, required)
        |> Keyword.put_new(:internal, false)

      if required do
        @required_fields unquote(name)
      end

      @schema_fields {unquote(name), unquote(type), opts}
    end
  end

  def embedded?(module) do
    function_exported?(module, :__schema__, 2)
  end
end
