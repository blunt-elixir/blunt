defmodule Blunt.EntityTestMessages.Protocol do
  defmodule Entity1 do
    use Blunt.Entity
  end

  defmodule Entity2 do
    use Blunt.Entity, identity: {:ident, :binary_id, []}
  end
end
