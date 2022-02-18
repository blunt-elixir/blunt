defmodule Support.Testing.FactoryComposition.CreateProduct do
  use Cqrs.Command
  field :id, :binary_id
end

defmodule Support.Testing.FactoryComposition.CreateProductPipeline do
  use Cqrs.CommandPipeline

  def handle_dispatch(%{id: id}, _context) do
    %{id: id}
  end
end

defmodule Support.Testing.FactoryComposition.CreatePolicy do
  use Cqrs.Command
  field :product_id, :binary_id
  field :id, :binary_id
end

defmodule Support.Testing.FactoryComposition.CreatePolicyPipeline do
  use Cqrs.CommandPipeline

  def handle_dispatch(%{id: id}, _context) do
    %{id: id}
  end
end

defmodule Support.Testing.FactoryComposition.CreatePolicyFee do
  use Cqrs.Command
  field :policy_id, :binary_id
  field :id, :binary_id
end

defmodule Support.Testing.FactoryComposition.CreatePolicyFeePipeline do
  use Cqrs.CommandPipeline

  def handle_dispatch(command, _context) do
    command
  end
end
