if Code.ensure_loaded?(ExMachina) and Code.ensure_loaded?(Faker) do
  defmodule Blunt.Testing.Factories.Values do
    alias Blunt.Testing.Factories.Factory

    defmodule Constant do
      @moduledoc false
      @derive Inspect
      defstruct [:field, :value]
    end

    @doc """
    The `field` of the factory source data will be assigned
    to the value
    """
    defmacro const(field, value) do
      quote do
        %Constant{field: unquote(field), value: unquote(value)}
      end
    end

    defmodule Data do
      @moduledoc false
      @derive Inspect
      defstruct [:field, :factory, lazy: false]
    end

    @doc """
    If the `field` is not supplied to the factory,
    the given `message` will be dispatched with the returned
    data to be put into the factory source data under the `field` key.
    """
    defmacro data(field, message, values \\ []) do
      quote do
        %Data{
          field: unquote(field),
          factory: Factory.new(:dependency, unquote(message), unquote(values), true)
        }
      end
    end

    @doc """
    Same as `data` but
    """
    defmacro lazy_data(field, message, values \\ []) do
      quote do
        %Data{
          lazy: true,
          field: unquote(field),
          factory: Factory.new(:dependency, unquote(message), unquote(values), true)
        }
      end
    end

    defmodule Prop do
      @moduledoc false
      @derive {Inspect, except: [:lazy]}
      defstruct [:field, :value_path_or_func, lazy: false]
    end

    @doc """
    The `field` of the factory source data will be assigned
    to the value of `value_path_or_func` in the factory source
    """
    defmacro prop(field, value_path_or_func) do
      quote do
        %Prop{field: unquote(field), value_path_or_func: unquote(value_path_or_func)}
      end
    end

    @doc """
    The `field` of the factory source data will be assigned
    to the value of `value_path_or_func` in the factory source
    """
    defmacro lazy_prop(field, value_path_or_func) do
      quote do
        %Prop{field: unquote(field), value_path_or_func: unquote(value_path_or_func), lazy: true}
      end
    end
  end
end
