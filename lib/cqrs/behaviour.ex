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
      {:ok, module} -> module
      {:error, error} -> raise Error, message: error
    end
  end

  # A reasonable subset of Ecto.Repo callbacks. Some Repos are not reporting back some of the callbacks.
  @ecto_repo_callbacks [
    __adapter__: 0,
    all: 1,
    checkout: 1,
    config: 0,
    delete: 1,
    delete!: 1,
    delete_all: 1,
    exists?: 1,
    get: 2,
    get!: 2,
    get_by: 2,
    get_by!: 2,
    insert: 1,
    insert_all: 2,
    one: 1
  ]
  defp has_all_callbacks?(module, Ecto.Repo) do
    Enum.all?(@ecto_repo_callbacks, fn {name, arity} ->
      function_exported?(module, name, arity)
    end)
  end

  defp has_all_callbacks?(module, behaviour_module) do
    callbacks = behaviour_module.behaviour_info(:callbacks)

    Enum.all?(callbacks, fn {name, arity} ->
      function_exported?(module, name, arity)
    end)
  end
end
