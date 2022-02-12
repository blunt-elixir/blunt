defmodule Cqrs.CommandTest.Protocol do
  defmodule CommandOptions do
    use Cqrs.Command

    option :debug, :boolean, default: false
    option :audit, :boolean, default: true
  end

  defmodule DispatchNoPipeline do
    use Cqrs.Command

    field :name, :string, required: true
    field :dog, :string, default: "maize"
  end

  defmodule CommandViaCommandMacro do
    use Cqrs

    defcommand do
      field :name, :string, required: true
      field :dog, :string, default: "maize"
    end
  end

  defmodule DispatchWithPipeline do
    use Cqrs.Command

    field :name, :string, required: true
    field :dog, :string, default: "maize"

    option :reply_to, :pid, required: true
    option :return_error, :boolean, default: false
  end

  defmodule CommandWithMeta do
    use Cqrs.Command

    metadata :auth,
      user_roles: [:owner, :collaborator],
      account_types: [:broker, :carrier]
  end
end
