defmodule Support.ContextTest.UsersContext do
  use Blunt.Context
  alias Support.ContextTest.{CreatePerson, GetPerson}

  command CreatePerson
  command CreatePerson, as: :create_person2
  command CreatePerson, as: :create_person_with_custom_opts, send_notification: true

  query GetPerson
  query GetPerson, as: :get_known_user, field_values: [id: "07faaf1d-5890-4391-a6db-50e86c240965"]
end
