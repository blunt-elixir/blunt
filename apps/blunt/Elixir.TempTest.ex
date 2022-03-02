defmodule TempTest do
  defp raise_function_replaced_error(old_function, new_function) do
    :erlang.error(
      RuntimeError.exception(
        <<"", String.Chars.to_string(old_function)::binary(),
          " has been removed.\n\nIf you are using ExMachina.Ecto, use ", String.Chars.to_string(new_function)::binary(),
          " instead.\n\nIf you are using ExMachina with a custom `save_record/2`, you now must use ExMachina.Strategy.\nSee the ExMachina.Strategy documentation for examples.\n">>
      ),
      :none,
      error_info: %{module: Exception}
    )
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
    ExMachina.build_pair(TempTest, factory_name, attrs)
  end

  def build_pair(x0) do
    super(x0, %{})
  end

  def build_list(number_of_records, factory_name, attrs) do
    ExMachina.build_list(TempTest, number_of_records, factory_name, attrs)
  end

  def build_list(x0, x1) do
    super(x0, x1, %{})
  end

  def build(factory_name, attrs) do
    ExMachina.build(TempTest, factory_name, attrs)
  end

  def build(x0) do
    super(x0, %{})
  end

  def bispatch_pair(factory_name, attrs, opts) do
    bispatch_list(2, factory_name, attrs, opts)
  end

  def bispatch_pair(factory_name, attrs) do
    bispatch_list(2, factory_name, attrs)
  end

  def bispatch_pair(x0) do
    super(x0, %{})
  end

  def bispatch_list(number_of_records, factory_name, attrs, opts) do
    Enum.take(Stream.repeatedly(fn -> bispatch(factory_name, attrs, opts) end), number_of_records)
  end

  def bispatch_list(number_of_records, factory_name, attrs) do
    Enum.take(Stream.repeatedly(fn -> bispatch(factory_name, attrs) end), number_of_records)
  end

  def bispatch_list(x0, x1) do
    super(x0, x1, %{})
  end

  def bispatch(factory_name, attrs, opts) do
    record = ExMachina.build(TempTest, factory_name, attrs)
    bispatch(record, opts)
  end

  def bispatch(already_built_record, function_opts) do
    opts = :maps.merge(Map.new([]), %{factory_module: TempTest})

    :erlang.apply(Blunt.Testing.Factories.DispatchStrategy, :handle_bispatch, [
      already_built_record,
      opts,
      function_opts
    ])
  end

  def bispatch(factory_name, attrs) do
    record = ExMachina.build(TempTest, factory_name, attrs)
    bispatch(record)
  end

  def bispatch(already_built_record) do
    opts = :maps.merge(Map.new([]), %{factory_module: TempTest})

    :erlang.apply(Blunt.Testing.Factories.DispatchStrategy, :handle_bispatch, [
      already_built_record,
      opts
    ])
  end

  def bispatch(factory_name) do
    record = ExMachina.build(TempTest, factory_name, %{})
    bispatch(record)
  end

  defmacro __using__(opts) do
    {:use, [context: Blunt.Data.Factories, import: Kernel], [{:__aliases__, [alias: false], [:Blunt, :Factories]}]}
  end
end
