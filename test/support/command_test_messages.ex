defmodule Blunt.CommandTest.Protocol do
  defmodule CommandOptions do
    use Blunt.Command

    option :debug, :boolean, default: false
    option :audit, :boolean, default: true
  end

  defmodule DispatchNoPipeline do
    use Blunt.Command

    field :name, :string, required: true
    field :dog, :string, default: "maize"
  end

  defmodule CommandViaCommandMacro do
    use Blunt

    defcommand do
      field :name, :string, required: true
      field :dog, :string, default: "maize"
    end
  end

  defmodule DispatchWithPipeline do
    @moduledoc """
    This command has a pipeline that it will be dispatched to
    """
    use Blunt.Command, require_all_fields?: false

    field :name, :string, required: true
    field :dog, :string, default: "maize"

    option :reply_to, :pid, required: true
    option :return_error, :boolean, default: false
  end

  defmodule CommandWithMeta do
    use Blunt.Command

    metadata :auth,
      user_roles: [:owner, :collaborator],
      account_types: [:broker, :carrier]
  end
end
