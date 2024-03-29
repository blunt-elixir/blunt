# Used by "mix format"
locals_without_parens = [
  field: 2,
  field: 3,
  import_fields: 1,
  import_fields: 2,
  internal_field: 2,
  internal_field: 3,
  static_field: 2,
  static_field: 3,
  option: 2,
  option: 3,
  command: 1,
  command: 2,
  query: 1,
  query: 2,
  binding: 2,
  value_object: 1,
  value_object: 2,
  derive_event: 1,
  derive_event: 2,
  metadata: 2,
  require_at_least_one: 1,
  require_either: 1,
  require_exactly_one: 1
]

[
  import_deps: [:ecto, :blunt_data],
  locals_without_parens: locals_without_parens,
  line_length: 120,
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
