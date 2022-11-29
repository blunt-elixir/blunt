defmodule Blunt.Absinthe.MutationResolver do
  alias Blunt.Absinthe.Message

  @callback resolve(Absinthe.Resolution.t(), keyword()) :: Absinthe.Resolution.t()

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro absinthe_resolver({:fn, _, [{:->, _, [[{_resolution, _, _}, {_config, _, _}], _]}]} = function) do
    quote do
      @behaviour unquote(__MODULE__)
      @impl unquote(__MODULE__)
      @dialyzer {:nowarn_function, resolve: 2}
      def resolve(resolution, config) do
        result = unquote(function).(resolution, config)

        case result do
          {:ok, result} ->
            Absinthe.Resolution.put_result(resolution, {:ok, result})

          {:error, error} ->
            Absinthe.Resolution.put_result(resolution, {:error, error})

          %Absinthe.Resolution{} = resolution ->
            resolution

          x ->
            raise Error, message: "Expected {:ok, _} or {:error, _}. Got #{inspect(x)}"
        end
      end
    end
  end

  defmacro receive_event(resolution, timeout \\ 5000, do: code_block) do
    quote do
      receive do
        unquote(code_block)
      after
        unquote(timeout) ->
          Absinthe.Resolution.put_result(unquote(resolution), {:error, :timeout})
      end
    end
  end

  def after_resolve(%{errors: [_ | _]} = resolution, _config), do: resolution

  def after_resolve(%{context: context, errors: []} = resolution, config) do
    case Map.get(context, :blunt, %{}) do
      %{message_module: module} ->
        cond do
          Message.defines_resolver?(module) ->
            module.resolve(resolution, config)

          true ->
            resolution
        end

      _ ->
        resolution
    end
  end
end
