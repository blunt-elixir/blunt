defmodule Mix.Tasks.Cqrs.Verify do
  use Mix.Task

  alias Cqrs.DispatchStrategy.PipelineResolver

  @options strict: [namespace: :string],
           aliases: [n: :namespace]

  def run(args) do
    Mix.Task.run("app.start", ["--no-start"])

    args
    |> get_namespace!()
    |> find_messages_without_pipelines()
    |> Enum.to_list()
    |> IO.inspect(label: "messages without pipelines")
  end

  defp find_messages_without_pipelines(namespace) do
    resolver = PipelineResolver.resolver()

    namespace
    |> find_messages()
    |> Stream.filter(&(Cqrs.Message in behaviours(&1)))
    |> Stream.map(&{&1, resolver.resolve(&1)})
    |> Stream.filter(&match?({_, :error}, &1))
    |> Stream.map(&elem(&1, 0))
  end

  defp find_messages(namespace) when is_binary(namespace) do
    modules =
      :code.all_available()
      |> Enum.filter(fn {name, _file, _loaded} -> String.starts_with?(to_string(name), namespace) end)
      |> Enum.map(fn {name, _file, _loaded} -> List.to_atom(name) end)

    with :ok <- :code.ensure_modules_loaded(modules) do
      modules
    end
  end

  defp behaviours(module) do
    module.module_info()
    |> get_in([:attributes, :behaviour])
    |> List.wrap()
  end

  defp get_namespace!(args) do
    {opts, _} = OptionParser.parse!(args, @options)
    "Elixir." <> Keyword.fetch!(opts, :namespace)
  end
end
