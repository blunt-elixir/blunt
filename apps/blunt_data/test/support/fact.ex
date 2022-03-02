defmodule Support.Fact do
  use Blunt.Data.Factories

  defmodule MyStruct do
    defstruct [:id, :name]
  end

  factory MyStruct, debug: true
end
