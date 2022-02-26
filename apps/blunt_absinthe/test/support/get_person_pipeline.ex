defmodule Blunt.Absinthe.Test.GetPersonPipeline do
  use Blunt.QueryPipeline

  alias Blunt.Repo
  alias Blunt.Absinthe.Test.ReadModel.Person

  @impl true
  def create_query(filters, _context) do
    if Keyword.get(filters, :error_out) do
      {:error, %{sumting: "wong"}}
    else
      query = from p in Person, as: :person

      Enum.reduce(filters, query, fn
        {:id, id}, query -> from([person: p] in query, where: p.id == ^id)
        _other, query -> query
      end)
    end
  end

  @impl true
  def handle_dispatch(query, _context, opts),
    do: Repo.one(query, opts)
end
