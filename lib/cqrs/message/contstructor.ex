defmodule Cqrs.Message.Contstructor do
  @moduledoc false

  alias Ecto.Changeset
  alias Cqrs.Message.Input
  alias __MODULE__, as: Constructor

  def generate(%{name: name, has_fields?: true, has_required_fields?: true}) do
    quote do
      @spec unquote(name)(values :: Input.t(), overrides :: Input.t()) ::
              {:ok, struct()} | {:error, any()}
      def unquote(name)(values, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def generate(%{name: name, has_fields?: true}) do
    quote do
      @spec unquote(name)(values :: Input.t(), overrides :: Input.t()) ::
              {:ok, struct()} | {:error, any()}
      def unquote(name)(values \\ %{}, overrides \\ []) when is_list(values) or is_map(values),
        do: Constructor.apply(__MODULE__, values, overrides)
    end
  end

  def generate(%{name: name}) do
    quote do
      @spec unquote(name)() ::
              {:ok, struct()} | {:error, any()}
      def unquote(name)(),
        do: Constructor.apply(__MODULE__, %{}, %{})
    end
  end

  def apply(module, values, overrides) do
    values = Input.normalize(values, module)
    overrides = Input.normalize(overrides, module)

    input = Map.merge(values, overrides)

    with {:ok, message} <- input |> module.changeset() |> handle_changeset() do
      {:ok, module.after_validate(message)}
    end
  end

  def handle_changeset(%{valid?: false} = changeset),
    do: {:error, format_errors(changeset)}

  def handle_changeset(changeset),
    do: Changeset.apply_action(changeset, :create)

  defp format_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
