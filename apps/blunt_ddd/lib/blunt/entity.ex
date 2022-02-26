defmodule Blunt.Entity do
  alias Blunt.Ddd.Constructor
  alias Blunt.Entity.Identity

  @callback identity(struct()) :: any()

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(opts) do
    quote do
      {identity, opts} = Identity.pop(unquote(opts))

      use Blunt.Message,
          [require_all_fields?: false]
          |> Keyword.merge(unquote(opts))
          |> Constructor.put_option()
          |> Keyword.put(:dispatch?, false)
          |> Keyword.put(:message_type, :entity)
          |> Keyword.put(:primary_key, identity)

      @behaviour Blunt.Entity
      @before_compile Blunt.Entity
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      require Identity
      require Constructor

      Identity.generate()
      Constructor.generate(return_type: :struct)
    end
  end
end
