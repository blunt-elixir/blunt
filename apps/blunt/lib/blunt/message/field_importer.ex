defmodule Blunt.Message.FieldImporter do
  @moduledoc false
  alias Blunt.Message.Metadata
  alias Blunt.Message.FieldImporter

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :field_modules, accumulate: true)

      import unquote(__MODULE__), only: :macros
    end
  end

  def import_fields(module, opts \\ []) when is_list(opts) do
    quote do
      @field_modules {unquote(module), unquote(opts)}
    end
  end

  @except [:discarded_data]

  def __import_fields__({source_module, opts}) do
    transform = Keyword.get(opts, :transform, &Function.identity/1)

    except = Keyword.get(opts, :except, @except)
    except = Enum.uniq(List.wrap(except) ++ @except)

    only = Keyword.get(opts, :only, Metadata.field_names(source_module) -- except)
    only = Enum.uniq(List.wrap(only))

    include_internal_fields = Keyword.get(opts, :include_internal_fields, false)

    source_module
    |> Metadata.fields()
    |> Enum.filter(fn {name, _type, _opts} -> Enum.member?(only, name) end)
    |> Enum.reject(fn {_name, _type, opts} ->
      if include_internal_fields, do: false, else: Keyword.get(opts, :internal)
    end)
    |> Enum.flat_map(fn {name, type, opts} ->
      opts = Macro.escape(opts)

      case transform.({name, type, opts}) do
        fields when is_list(fields) -> fields
        field -> [field]
      end
    end)
  end

  defmacro __before_compile__(%{module: module}) do
    imported_fields =
      module
      |> Module.get_attribute(:field_modules)
      |> Enum.flat_map(&FieldImporter.__import_fields__/1)

    Enum.map(imported_fields, fn {name, type, opts} ->
      quote do
        field unquote(name), unquote(type), unquote(opts)
      end
    end)
  end
end
