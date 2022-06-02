defmodule Blunt.Test.CompilerHooks do
  def add_user_id_field(_env) do
    quote do
      field :user_id, :binary_id
    end
  end
end
