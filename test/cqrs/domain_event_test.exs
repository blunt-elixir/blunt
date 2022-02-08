defmodule Cqrs.DomainEventTest do
  use ExUnit.Case, async: true

  alias Cqrs.DomainEventTest.Protocol.{DefaultEvent, EventWithSetVersion}

  test "is version 1 by default" do
    assert %DefaultEvent{version: 1} = DefaultEvent.create(%{})
  end

  test "version is settable" do
    assert %EventWithSetVersion{version: 2} = EventWithSetVersion.create(%{})
  end
end
