defmodule Blunt.Absinthe.Args do
  @moduledoc false

  # TODO: Document parent_mappings and arg_transforms

  alias Blunt.Message.Metadata
  alias Blunt.Absinthe.{Log, Type}

  @type message_module :: atom()
  @spec from_message_fields(message_module, keyword) :: list

  def from_message_fields(message_module, opts) do
    message_module
    |> Metadata.fields()
    |> filter(opts)
    |> reject(:internal, opts)
    |> reject(:parent_mapped_fields, opts)
    |> update(:add_absinthe_types, message_module, opts)
    |> update(:set_absinthe_type_opts, opts)
    |> convert(:to_quoted_absinthe_args, opts)
  end

  @spec resolve_message_input(map(), {atom(), map(), keyword()}) :: any
  def resolve_message_input(args, {message_module, parent, opts}) do
    field_mappings = Keyword.get(opts, :parent_mappings, [])
    arg_transforms = Keyword.get(opts, :arg_transforms, [])

    args
    |> update(:resolve_parent_mappings, {message_module, parent, field_mappings})
    |> update(:run_arg_transforms, {message_module, arg_transforms})
  end

  defp convert(fields, :to_quoted_absinthe_args, opts) do
    declared_required_field_names = Keyword.get(opts, :required, [])

    Enum.map(fields, fn {name, {_type, absinthe_type}, _field_opts} = field ->
      {type, opts} = absinthe_type

      if required?(field, declared_required_field_names) do
        quote do: arg(unquote(name), non_null(unquote(type)), unquote(opts))
      else
        quote do: arg(unquote(name), unquote(type), unquote(opts))
      end
    end)
  end

  defp required?({name, _type, field_opts}, declared_required_field_names) do
    Enum.member?(declared_required_field_names, name) || Keyword.get(field_opts, :required, false)
  end

  defp update(absinthe_args, :run_arg_transforms, {message_module, arg_transforms}) do
    Enum.reduce(arg_transforms, absinthe_args, fn
      {field_name, transform_fun}, acc when is_function(transform_fun, 1) ->
        Map.update(acc, field_name, nil, fn source ->
          transformed = transform_fun.(source)

          Log.debug(
            "Transformed #{inspect(message_module)}.#{field_name}: #{inspect(source)} -> #{inspect(transformed)}"
          )

          Log.debug(
            "Transformed #{inspect(message_module)}.#{field_name}: #{inspect(source)} -> #{inspect(transformed)}"
          )

          transformed
        end)

      {field_name, _transform_fun}, acc ->
        Log.warning(
          "Invalid Field Transformation for #{inspect(message_module)}.#{field_name}. Expected a function with an arity of 1"
        )

        acc
    end)
  end

  defp update(absinthe_args, :resolve_parent_mappings, {message_module, parent, field_mappings}) do
    Enum.reduce(field_mappings, absinthe_args, fn
      {field_name, resolver_fun}, acc when is_function(resolver_fun, 1) ->
        value = resolver_fun.(parent)
        Log.debug("Resolved #{inspect(message_module)}.#{field_name} from parent: #{inspect(value)}")
        Map.put(acc, field_name, value)

      {field_name, resolver_fun}, acc when is_function(resolver_fun, 2) ->
        value = resolver_fun.(parent, absinthe_args)
        Log.debug("Resolved #{inspect(message_module)}.#{field_name} from parent: #{inspect(value)}")
        Map.put(acc, field_name, value)

      {field_name, _resolver_fun}, acc ->
        Log.warning(
          "Invalid Field Mapping for #{inspect(message_module)}.#{field_name}. Expected a function with an arity of 1 or 2"
        )

        acc
    end)
  end

  defp update(fields, :set_absinthe_type_opts, _opts) do
    Enum.map(fields, fn {name, {type, absinthe_type}, field_opts} ->
      description = Keyword.get(field_opts, :desc)
      default_value = Keyword.get(field_opts, :default) |> Macro.escape()

      absinthe_type_opts =
        field_opts
        |> Keyword.take([:deprecate, :name])
        |> Keyword.put(:description, description)
        |> Keyword.put(:default_value, default_value)

      absinthe_type =
        case absinthe_type do
          {absinthe_type, opts} -> {absinthe_type, Keyword.merge(opts, absinthe_type_opts)}
          absinthe_type -> {absinthe_type, absinthe_type_opts}
        end

      {name, {type, absinthe_type}, field_opts}
    end)
  end

  defp update(fields, :add_absinthe_types, message_module, opts) do
    Enum.map(fields, fn {field_name, type, field_opts} = field ->
      absinthe_type = Type.from_message_field(message_module, field, opts)
      {field_name, {type, absinthe_type}, field_opts}
    end)
  end

  defp reject(fields, :internal, _opts) do
    Enum.reject(fields, fn {_name, _type, opts} -> Keyword.get(opts, :internal, false) == true end)
  end

  defp reject(fields, :parent_mapped_fields, opts) do
    field_mappings = Keyword.get(opts, :parent_mappings, []) |> Keyword.keys()
    Enum.reject(fields, fn {field, _, _} -> Enum.member?(field_mappings, field) end)
  end

  defp filter(fields, opts) do
    only = Keyword.get(opts, :only, [])
    except = Keyword.get(opts, :except, [])

    case {only, except} do
      {[], []} -> fields
      {[], except} -> Enum.reject(fields, &Enum.member?(except, elem(&1, 0)))
      {only, []} -> Enum.filter(fields, &Enum.member?(only, elem(&1, 0)))
      _ -> raise "You can only specify :only or :except"
    end
  end
end
