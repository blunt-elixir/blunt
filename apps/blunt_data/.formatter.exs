# Used by "mix format"
locals_without_parens = [
  # blunt data factories macros
  builder: 1,
  factory: 1,
  factory: 2,
  factory: 3,
  const: 2,
  fake: 2,
  child: 2,
  data: 2,
  data: 3,
  map: 1,
  lazy_data: 2,
  lazy_data: 3,
  prop: 2,
  prop: 3,
  merge_prop: 2,
  merge_prop: 3,
  lazy_prop: 2,
  required_prop: 1,
  required_props: 1,
  defaults: 1,
  merge_input: 1,
  input: 1,
  inspect_props: 0,
  inspect_props: 1
  inspect_prop_keys: 0
]

[
  locals_without_parens: locals_without_parens,
  line_length: 120,
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
