defmodule BluntCommanded.Router do
  @moduledoc false
  use Commanded.Commands.Router

  alias BluntCommanded.Test.Protocol.{CreateUser, UpdateUser}

  dispatch([CreateUser, UpdateUser])
end
