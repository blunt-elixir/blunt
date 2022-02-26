defmodule Support.ContextTest.CreatePerson do
  use Blunt.Command

  field :name, :string

  field :id, :binary_id,
    desc: "Id is set internally. Setting it will have no effect.",
    required: false

  option :send_notification, :boolean, default: false

  @impl true
  def after_validate(command) do
    Map.put(command, :id, UUID.uuid4())
  end
end
