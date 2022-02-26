defmodule Blunt.Absinthe.Relay.Connection do
  @moduledoc false

  require Logger

  alias Blunt.Absinthe.Relay.Connection

  def generate_total_count_field do
    quote do
      field :total_count, :integer, resolve: &Connection.resolve_total_count/3
    end
  end

  def resolve_total_count(%{query: query, repo: repo}, _args, _res) do
    {:ok, repo.aggregate(query, :count, :id)}
  end

  def resolve_total_count(_connection, _args, _res) do
    Logger.warn("Requested total_count on a connection that was not created by blunt.")
    {:ok, nil}
  end
end
