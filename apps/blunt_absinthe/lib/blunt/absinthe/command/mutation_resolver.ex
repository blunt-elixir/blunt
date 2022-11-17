defmodule Blunt.Absinthe.Command.MutationResolver do
  @callback resolve(Absinthe.Resolution.t(), keyword()) :: Absinthe.Resolution.t()

  defmodule Error do
    defexception [:message]
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @dialyzer {:nowarn_function, resolve: 2}
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro absinthe_resolver({:fn, _, [{:->, _, [[{_resolution, _, _}, {_config, _, _}], _]}]} = function) do
    quote do
      @impl unquote(__MODULE__)
      def resolve(resolution, config) do
        unquote(function).(resolution, config)
      end
    end
  end

  defmacro receive_event(resolution, timeout \\ 5000, do: code_block) do
    quote do
      result =
        receive do
          unquote(code_block)
        after
          unquote(timeout) ->
            Absinthe.Resolution.put_result(unquote(resolution), {:error, :timeout})
        end

      case result do
        {:ok, result} ->
          Absinthe.Resolution.put_result(unquote(resolution), {:ok, result})

        {:error, error} ->
          Absinthe.Resolution.put_result(unquote(resolution), {:error, error})

        x ->
          raise Error, message: "Expected {:ok, _} or {:error, _}. Got #{inspect(x)}"
      end
    end
  end
end
