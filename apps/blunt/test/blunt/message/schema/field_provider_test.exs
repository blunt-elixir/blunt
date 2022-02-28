defmodule Blunt.Message.Schema.FieldProviderTest do
  use ExUnit.Case, async: false
  use Blunt.Testing.Factories

  alias Blunt.Config
  alias Blunt.Message.Schema.FieldProvider
  # alias Support.Message.Schema.EmailFieldProvider

  @moduledoc """
  Blunt gives you a pretty painless way of defining your own field types.

  Along with custom field types, it offers a way to add validations, via a tuple name;
  and also hook to provide fake data to `Blunt.Testing.Factories`.

  To accomplish this, you just need to implement and configure a simple behaviour to blunt.

  ## Example

      defmodule EmailFieldProvider do
        @behaviour Blunt.Message.Schema.FieldProvider

        alias Ecto.Changeset
        alias Blunt.Message.Schema

        @impl true
        def ecto_field(module, {name, :email, opts}) do
          quote bind_quoted: [module: module, name: name, opts: opts] do
            Schema.put_field_validation(module, name, :email)
            Ecto.Schema.field(name, :string, opts)
          end
        end

        def ecto_field(_module, _field_definition), do: nil

        @impl true
        def validate_changeset(:email, field_name, changeset, _module) do
          Changeset.validate_format(changeset, field_name, ~r/@/)
        end

        def validate_changeset(:begin_with_capital_letter, field_name, changeset, _module) do
          Changeset.validate_format(changeset, field_name, ~r/^[A-Z].+/, message: "must begin with a capital letter")
        end

        @impl true
        def fake(:email, _validation, _field_config) do
          send(self(), :email_field_faked)
          "fake_hombre@example.com"
        end

        def fake(_field_type, :begin_with_capital_letter, _field_config) do
          send(self(), :begin_with_capital_letter_validation_field_faked)
          "Chris"
        end
      end

  """

  # *****************************************************
  # And pop it in your config.exs
  # like this:
  #   config :blunt, schema_field_providers: [EmailFieldProvider]
  # *****************************************************
  # Of course, it seems a little foreign. But you can test
  # your implementation by copying this file and tweaking it out.
  #
  # After that, you only have to define fields as normal, but with your
  # types and validations.
  # *****************************************************
  #
  # =====================================================
  # BEGIN TESTS
  # =====================================================

  describe "blunt config" do
    alias Blunt.Message.Schema.DefaultFieldProvider

    test "having the default provider configured, it won't be registered twice" do
      assert [DefaultFieldProvider] = Config.schema_field_providers(providers: DefaultFieldProvider)
    end

    @tag providers: [DefaultFieldProvider, DefaultFieldProvider]
    test "even having multiple default providers configured, it won't be registered twice" do
      assert [DefaultFieldProvider] =
               Config.schema_field_providers(providers: [DefaultFieldProvider, DefaultFieldProvider])
    end
  end

  describe "custom `email` field" do
    defmodule CustomFields do
      use Blunt.Message

      field :email_address, :email, required: true
      field :email_address2, :email, required: false
    end

    factory CustomFields, debug: false

    test "it even *compiles* 😎" do
      assert %{email_address: "chris@example.com"} = build(:custom_fields, email_address: "chris@example.com")
    end

    test "email validations" do
      assert {:error, %{email_address: ["has invalid format"]}} = build(:custom_fields, email_address: "notanemail")

      assert {:error, %{email_address2: ["has invalid format"]}} =
               build(:custom_fields, email_address: "chris@example.com", email_address2: "notanemail")
    end
  end

  describe "custom validations" do
    defmodule CustomValidations do
      use Blunt.Message

      field :name, :string, validate: :begin_with_capital_letter
    end

    factory CustomValidations

    test "begin_with_capital_letter validation" do
      assert {:error, %{name: ["must begin with a capital letter"]}} = build(:custom_validations, name: "chris")

      assert %CustomValidations{name: "Chris"} = build(:custom_validations, name: "Chris")
    end
  end

  describe "fake data" do
    test "email field type provides fake data" do
      field_type = :email
      validation = :doesnt_matter
      field_config = []

      assert "fake_hombre@example.com" == FieldProvider.fake(field_type, field_config, validation: validation)
    end

    test "field with `validate: begin_with_capital_letter` provides fake data" do
      field_type = :doesnt_matter
      validation = :begin_with_capital_letter
      field_config = []

      assert "Chris" == FieldProvider.fake(field_type, field_config, validation: validation)
    end
  end

  describe "using the field provider module as a type" do
    alias Support.Message.Schema.EmailFieldProvider

    defmodule UseModuleAsType do
      use Blunt.Message
      field :email_address, EmailFieldProvider
    end

    factory UseModuleAsType, debug: false

    test "works as intended" do
      assert %{email_address: "fake_hombre@example.com"} = build(:use_module_as_type)
    end
  end
end
