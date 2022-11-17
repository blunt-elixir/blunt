# Used by "mix format"
locals_without_parens = [
  derive_enum: 2,
  derive_query: 2,
  derive_query: 3,
  derive_mutation: 2,
  derive_mutation: 3,
  derive_object: 2,
  derive_object: 3,
  derive_mutation_input: 1,
  derive_mutation_input: 2,
  absinthe_resolver: 1
]

[
  locals_without_parens: locals_without_parens,
  line_length: 120,
  import_deps: [:absinthe, :blunt, :ecto],
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
