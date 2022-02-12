defmodule Cqrs.Message.Opts do
  @moduledoc false
  def primary_key(opts) do
    case Keyword.get(opts, :primary_key, false) do
      {:{}, [], [name, type, config]} -> {name, type, config}
      value -> value
    end
  end
end
