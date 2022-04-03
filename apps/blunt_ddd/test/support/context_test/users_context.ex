defmodule Support.ContextTest.UsersContext do
  use Blunt.BoundedContext
  alias Support.ContextTest.{CreatePerson, GetPerson, ZeroFieldQuery}

  blunt_command CreatePerson
  blunt_command CreatePerson, as: :create_person2
  blunt_command CreatePerson, as: :create_person_with_custom_opts, send_notification: true

  blunt_query GetPerson
  blunt_query GetPerson, as: :get_known_user, field_values: [id: "07faaf1d-5890-4391-a6db-50e86c240965"]
  blunt_query ZeroFieldQuery
end
