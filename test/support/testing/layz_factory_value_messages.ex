defmodule Support.Testing.LayzFactoryValueMessages.CreateProduct do
  use Blunt.Command
  field :id, :binary_id
end

defmodule Support.Testing.LayzFactoryValueMessages.CreateProductPipeline do
  use Blunt.CommandPipeline

  def handle_dispatch(%{id: id}, _context) do
    %{id: id}
  end
end

defmodule Support.Testing.LayzFactoryValueMessages.CreatePolicy do
  use Blunt.Command
  field :product_id, :binary_id
  field :id, :binary_id
end

defmodule Support.Testing.LayzFactoryValueMessages.CreatePolicyPipeline do
  use Blunt.CommandPipeline

  def handle_dispatch(%{id: id}, _context) do
    %{id: id}
  end
end

defmodule Support.Testing.LayzFactoryValueMessages.CreatePolicyFee do
  use Blunt.Command
  field :policy_id, :binary_id
  field :id, :binary_id
end

defmodule Support.Testing.LayzFactoryValueMessages.CreatePolicyFeePipeline do
  use Blunt.CommandPipeline

  def handle_dispatch(command, _context) do
    command
  end
end
