# Used by "mix format"
locals_without_parens = [
  command: 1,
  command: 2,
  query: 1,
  query: 2,
  defcontext: 1,
  defevent: 1,
  defevent: 2,
  defvalue: 1,
  defvalue: 2,
  defentity: 1,
  defentity: 2,
  derive_event: 1,
  derive_event: 2,
  derive_event: 3
]

[
  locals_without_parens: locals_without_parens,
  line_length: 120,
  import_deps: [:blunt, :ecto],
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
