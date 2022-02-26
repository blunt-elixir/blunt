defmodule Blunt.Ddd.Constructor do
  @moduledoc false

  alias Blunt.Message.Input

  def put_option(opts),
    do: Keyword.put(opts, :constructor, :__new__)

  @spec generate(keyword()) :: any()
  defmacro generate(return_type: return_type) do
    quote do
      @type values :: Input.t()
      @type overrides :: Input.t()

      @spec new(values(), overrides()) :: struct() | {:error, any()}
      def new(values, overrides \\ []),
        do: Blunt.Ddd.Constructor.new(__MODULE__, values, overrides, return_type: unquote(return_type))
    end
  end

  def new(module, values, overrides, opts) do
    with {:ok, entity, _discarded_data} <- module.__new__(values, overrides) do
      case Keyword.get(opts, :return_type, :tagged_tuple) do
        :tagged_tuple -> {:ok, entity}
        :struct -> entity
      end
    end
  end
end
