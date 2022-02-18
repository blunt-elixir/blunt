# MessageName

## Fields

### required 

* `id` - `:binary_id` - The id of the entity.

### optional

* `age` - `:integer` - Are you old?

    * default value: `nil`

* `dog` - `:enum` - Tell me what dog is yours.

    * default value: `nil`    
    * possible values: [`:jake`, `:maize`, `:phoenix`, `:kent`]

## Options

* `return` - `:enum` - Determines what data to return when the command is dispatched. 

    * default value: `:response`  
    * possible values: [`:response`, `:context`]
 
    > Setting the value to `:context` will return the whole `DispatchContext`.
    > Setting the value to `:response` will return just the value returned from the command.

@moduledoc """

"""
