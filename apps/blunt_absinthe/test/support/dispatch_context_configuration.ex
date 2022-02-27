defmodule Blunt.Absinthe.Test.DispatchContextConfiguration do
  @behaviour Blunt.Absinthe.DispatchContext.Configuration

  def configure(%{context: context}) do
    context
    |> Map.take([:user, :reply_to])
    |> Enum.to_list()
  end
end
