defmodule Cqrs.Message.Changeset do
  @moduledoc false

  alias Ecto.Changeset
  alias Cqrs.Message.Input
  alias Cqrs.Message.Changeset, as: MessageChangeset

  defmacro generate do
    quote do
      def changeset(message \\ %__MODULE__{}, values)

      def changeset(message, values) when is_struct(values),
        do: changeset(message, Map.from_struct(values))

      def changeset(%{__struct__: message}, values) when is_list(values) or is_map(values),
        do: changeset(message, values)

      def changeset(message, values) when is_list(values) or is_map(values),
        do: MessageChangeset.create(message, values, @required_fields)
    end
  end

  @type message :: atom()
  @type discarded_data :: map()
  @type changeset :: Ecto.Changeset.t()
  @type required_fields :: atom() | list
  @type values :: maybe_improper_list | map | struct

  @spec create(message(), values(), required_fields) :: {changeset, discarded_data}

  def create(message, values, required_fields) do
    values = Input.normalize(values, message)

    embeds = message.__schema__(:embeds)
    fields = message.__schema__(:fields)

    discarded_data =
      values
      |> Map.drop(Enum.map(fields, &to_string/1))
      |> Map.drop(Enum.map(embeds, &to_string/1))

    changeset =
      message
      |> struct()
      |> Changeset.cast(values, fields -- embeds)

    changeset =
      embeds
      |> Enum.reduce(changeset, &Changeset.cast_embed(&2, &1))
      |> Changeset.validate_required(required_fields)
      |> message.handle_validate()

    {changeset, discarded_data}
  end
end
