# Used by "mix format"
locals_without_parens = [
  field: 2,
  field: 3,
  internal_field: 2,
  internal_field: 3,
  option: 2,
  option: 3,
  command: 1,
  command: 2,
  derive_event: 1,
  derive_event: 2,
  derive_event: 3,
  query: 1,
  query: 2,
  binding: 2,
  value_object: 1,
  value_object: 2,
  derive_event: 1,
  derive_event: 2
]

[
  locals_without_parens: locals_without_parens,
  line_length: 120,
  import_deps: [:ecto],
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
