defmodule Blunt.DomainEventTest do
  use ExUnit.Case, async: true

  alias Blunt.Message.Metadata

  alias Support.DomainEventTest.{
    DefaultEvent,
    EventWithSetVersion,
    EventWithDecimalVersion,
    EventDerivedFromCommand,
    EventDerivedFromCommandWithDrop
  }

  test "is version 1 by default" do
    assert %DefaultEvent{version: 1} = DefaultEvent.new(%{})
  end

  test "version is settable" do
    assert %EventWithSetVersion{version: 2} = EventWithSetVersion.new(%{})
  end

  test "version is decimal" do
    assert %EventWithDecimalVersion{version: 2.3} = EventWithDecimalVersion.new(%{})
  end

  test "EventDerivedFromCommand has fields from CommandToTestDerivation" do
    expected_fields = Metadata.field_names(CommandToTestDerivation)
    actual_fields = Metadata.field_names(EventDerivedFromCommand)

    assert Enum.all?(expected_fields, &Enum.member?(actual_fields, &1))
  end

  test "EventDerivedFromCommandWithDrop drops the name field from CommandToTestDerivation" do
    actual_fields = Metadata.field_names(EventDerivedFromCommandWithDrop)
    refute Enum.member?(actual_fields, :name)
  end
end
