defmodule Cqrs.Behaviour do
  @moduledoc false

  defmodule Error do
    defexception [:message]
  end

  @spec validate(atom, atom) :: {:error, String.t()} | {:ok, atom}

  def validate(module, behaviour_module) do
    error = "#{inspect(module)} is not a valid #{inspect(behaviour_module)}"

    case Code.ensure_compiled(module) do
      {:module, module} ->
        if has_all_callbacks?(module, behaviour_module),
          do: {:ok, module},
          else: {:error, error}

      _ ->
        {:error, error}
    end
  end

  @spec validate!(atom, atom) :: atom

  def validate!(module, behaviour_module) do
    case validate(module, behaviour_module) do
      {:ok, handler} -> handler
      {:error, error} -> raise Error, message: error
    end
  end

  defp has_all_callbacks?(handler, behaviour_module) do
    callbacks = behaviour_module.behaviour_info(:callbacks)

    Enum.all?(callbacks, fn {name, arity} ->
      function_exported?(handler, name, arity)
    end)
  end
end
