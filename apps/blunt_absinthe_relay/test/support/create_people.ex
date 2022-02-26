defmodule Blunt.Absinthe.Relay.Test.CreatePeople do
  use Blunt.Command
  alias Blunt.Absinthe.Relay.Test.Person

  field :peeps, {:array, Person}
end

defmodule Blunt.Absinthe.Relay.Test.CreatePeoplePipeline do
  use Blunt.CommandPipeline

  alias Blunt.Repo

  def handle_dispatch(%{peeps: peeps}, _context) do
    Enum.map(peeps, &Repo.insert!/1)
  end
end
