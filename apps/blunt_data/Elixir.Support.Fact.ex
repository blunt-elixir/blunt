defmodule Support.Fact do
  defp raise_function_replaced_error(old_function, new_function) do
    :erlang.error(
      RuntimeError.exception(
        <<"", String.Chars.to_string(old_function)::binary(),
          " has been removed.\n\nIf you are using ExMachina.Ecto, use ",
          String.Chars.to_string(new_function)::binary(),
          " instead.\n\nIf you are using ExMachina with a custom `save_record/2`, you now must use ExMachina.Strategy.\nSee the ExMachina.Strategy documentation for examples.\n">>
      ),
      :none,
      error_info: %{module: Exception}
    )
  end

  def my_struct_factory(input) do
    factory = %Blunt.Data.Factories.Factory{
      active_builder: nil,
      data: %{},
      dispatch?: false,
      field_validations: nil,
      fields: nil,
      final_message: nil,
      message_name: nil,
      input: input,
      name: :my_struct_factory,
      opts: [debug: true],
      values: [],
      message: Support.Fact.MyStruct,
      builders: [
        Blunt.Data.Factories.Builder.EctoSchemaBuilder,
        Blunt.Data.Factories.Builder.StructBuilder,
        Blunt.Data.Factories.Builder.MapBuilder
      ],
      fake_provider: Blunt.Data.Factories.FakeProvider.Default
    }

    Blunt.Data.Factories.Factory.build(factory)
  end

  def factory(factory_name) do
    :erlang.error(ExMachina.UndefinedFactoryError.exception(factory_name))
  end

  def create_pair(_, _) do
    raise_function_replaced_error("create_pair/2", "insert_pair/2")
  end

  def create_list(_, _, _) do
    raise_function_replaced_error("create_list/3", "insert_list/3")
  end

  def create(_, _) do
    raise_function_replaced_error("create/2", "insert/2")
  end

  def create(_) do
    raise_function_replaced_error("create/1", "insert/1")
  end

  def build_pair(factory_name, attrs) do
    ExMachina.build_pair(Support.Fact, factory_name, attrs)
  end

  def build_pair(x0) do
    super(x0, %{})
  end

  def build_list(number_of_records, factory_name, attrs) do
    ExMachina.build_list(Support.Fact, number_of_records, factory_name, attrs)
  end

  def build_list(x0, x1) do
    super(x0, x1, %{})
  end

  def build(factory_name, attrs) do
    ExMachina.build(Support.Fact, factory_name, attrs)
  end

  def build(x0) do
    super(x0, %{})
  end

  defmacro __using__(opts) do
    {:use, [context: Blunt.Data.Factories, import: Kernel],
     [{:__aliases__, [alias: false], [:Blunt, :Data, :Factories]}]}
  end
end