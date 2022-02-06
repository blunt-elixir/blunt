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

  def create(message, values, required_fields) do
    values = Input.normalize(values, message)

    embeds = message.__schema__(:embeds)
    fields = message.__schema__(:fields)

    discarded_input =
      values
      |> Map.drop(Enum.map(fields, &to_string/1))
      |> Map.drop(Enum.map(embeds, &to_string/1))

    changeset =
      message
      |> struct()
      |> Changeset.cast(values, fields -- embeds)
      |> Changeset.put_change(:discarded_input, discarded_input)

    embeds
    |> Enum.reduce(changeset, &Changeset.cast_embed(&2, &1))
    |> Changeset.validate_required(required_fields)
    |> message.handle_validate()
  end
end
