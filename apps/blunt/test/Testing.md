# Blunt Testing

You'll notice a lot of `build(:message_name)` calls in the test suite. This is simply taking advantage of the code in Blunt by cutting down on the noise in tests and allowing faster test authoring.

## Factories

The `Blunt.Testing.Factories` macro allows you to create factory functions for any Blunt message, Ecto schema, or even structs and plain maps.

And thanks to `[ex_machina](https://github.com/thoughtbot/ex_machina)`, you can `build`, `insert` (in the case of Ecto schemas), or `dispatch` a fully validated data structure.

### Example

```elixir
defmodule CreatePerson do
  use Blunt.Command

  field :id, :binary_id
  field :name, :string
  field :child_id, :binary_id, required: false
end

defmodule CreatePersonTest do
  use ExUnit.Case
  use Blunt.Testing.Factories
  
  factory CreatePerson

  test "build from factory" do
    %{id: id, name: name} = build(:create_person)

    assert {:ok, _} = UUID.info(id)
    refute nil == name

    id = "a174fc92-32f3-470d-8884-86b22520d47d"
    name = "chris"

    assert %{id: ^id, name: ^name} = 
    	build(:create_person, id: id, name: name)
  end

  factory :setup_data do
    lazy_data :data, CreateData, [const(:id, 1234)]
    prop :child_id, [:data, :child, :child_id]
    lazy_data :boss CreatePerson
    lazy_data :monkey CreatePerson
  end

  test "plain map factory" do
    %{data: %{id: 1234}, child_id: _something, boss: _boss_person, monkey: _not_really_human} = 
      build(:setup_data)      
  end
end
```

### Options

* `debug` **:boolean** - if `true`, will output a lot of useful information about the build process. This is very useful when composing factories with many values.
* `as` **:atom** - generates the factory with a custom name. Sometimes you want to define two different factories for the same message. Or your test case will be made more clear with a name different from the default of `:create_person` from the example above.

```elixir
factory CreatePerson, debug: true, as: :create_child
```

### Values

You can seed factory data in two ways.

#### Input

Simply pass values to the factory function you choose. 
```elixir
  test "build from factory" do
    id = "a174fc92-32f3-470d-8884-86b22520d47d"
    name = "chris"

    assert %{id: ^id, name: ^name} = 
    	build(:create_person, id: id, name: name)
  end
```

#### Value Declaration

You can also declare data in the factory definition itself. 

```elixir
factory CreatePerson, debug: true do
  const :name, "chris"
  lazy_data :child, CreatePerson
  prop :child_id, [:child, :id]
end

factory CreatePerson, as: :create_child, debug: true

test "build from factory" do
  assert %{id: id, name: "chris", child_id: child_id} = 
  	build(:create_person)

  assert {:ok, _} = UUID.info(id)
  assert {:ok, _} = UUID.info(child_id)

  %{id: child_id} = child = build(:create_child)

  assert %{name: "chris", child_id: ^child_id} = 
  	build(:create_person, child: child)
end
```

The values will be evaluated in the order in which they are declared.

There are currently three possible declarations.

##### Const

The `const` value will set the field to the compile-time value given.

##### Data

The `data` value will `dispatch` messages for data that the current factory relies on.

The message used to run the value must be a `dispatchable` message. `Blunt.Message.dispatchable?/1`

Under the covers, a `data` value is turned into another factory, so you may pass values to it as well.

```elixir
  lazy_data :child, CreatePerson, [const(:name, "hailey"), ...]
```

##### Lazy Data

The `lazy_data` value is a `data` value will be evaluated only if the key it is setting is not present in the factory data at the point of evaluation.

##### Prop

The `prop` value will evaluate and be stored in the given key.

The `prop` value can accept the following arguments as value accessors.

1. a path to the key in the current factory data. ie `prop :child_id, [:child, :id]`
2. an arity zero function. ie `prop :child_id, fn -> UUUID.uuid4()`
3. an arity one function that accepts the current factory data. ie `prop :child_id, fn %{child: child} -> child.id end` 

##### Lazy Prop

The `lazy_prop` value is a `prop` value will be evaluated only if the key it is setting is not present in the factory data at the point of evaluation.

### Usage

To use the factories, you can use any function that `ex_machina` provides or use `dispatch` for `blunt` messages.

#### Dispatch

This function takes a factory name -- and optionally some data -- builds, validates, and calls `dispatch` if the message was successfully built.

You can pass normal `dispatch` options in as the third argument.

```elixir
dispatch(:create_person, %{name: "chris"}, return: :context)
```



