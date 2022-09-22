defmodule OpentelemetryBluntTest do
  use ExUnit.Case

  require Record

  for {name, spec} <- Record.extract_all(from_lib: "opentelemetry/include/otel_span.hrl") do
    Record.defrecord(name, spec)
  end

  for {name, spec} <- Record.extract_all(from_lib: "opentelemetry_api/include/opentelemetry.hrl") do
    Record.defrecord(name, spec)
  end

  defmodule MyCommand do
    use Blunt.Command
    field :name, :string
  end

  defmodule MyQuery do
    use Blunt.Query
    field :name, :string
  end

  defmodule MyCommandHandler do
    use Blunt.CommandHandler

    def handle_dispatch(_command, _context), do: :all_done
  end

  defmodule MyQueryHandler do
    use Blunt.QueryHandler

    def create_query(_filters, _context) do
      %Ecto.Query{}
    end

    def handle_dispatch(_query, context, _opts) do
      %{name: name} = Blunt.Query.filters(context)
      %{__struct__: Person, name: name}
    end
  end

  setup do
    :application.stop(:opentelemetry)
    :application.set_env(:opentelemetry, :tracer, :otel_tracer_default)

    :application.set_env(:opentelemetry, :processors, [
      {:otel_batch_processor, %{scheduled_delay_ms: 1, exporter: {:otel_exporter_pid, self()}}}
    ])

    :application.start(:opentelemetry)

    TestHelpers.remove_blunt_handlers()
    OpentelemetryBlunt.setup()

    :ok
  end

  describe "dispatch" do
    setup do
      :otel_batch_processor.set_exporter(:otel_exporter_pid, self())
    end

    test "receives span" do
      %{name: "chris"}
      |> MyCommand.new()
      |> MyCommand.dispatch()

      assert_receive(
        {:span,
         span(
           name: "dispatch",
           attributes: attributes,
           parent_span_id: :undefined,
           status: :undefined
         )}
      )

      :otel_attributes.map(attributes)
      |> IO.inspect(label: "~/code/personal/blunt/apps/opentelemetry_blunt/test/opentelemetry_blunt_test.exs:79")
    end
  end
end
