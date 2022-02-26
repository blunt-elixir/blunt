# Used by "mix format"
locals_without_parens = [
  derive_connection: 3,
  define_connection: 2
]

[
  locals_without_parens: locals_without_parens,
  line_length: 120,
  import_deps: [:absinthe, :blunt, :blunt_absinthe, :ecto],
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
