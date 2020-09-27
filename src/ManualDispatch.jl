module ManualDispatch

import MacroTools

export @unionsplit

function _unionsplit(types, call)
    MacroTools.@capture(call, f_(arg_, args__))
    thetypes = types.args
    first_type, rest_types = Iterators.peel(thetypes)
    code = :(if $arg isa $first_type
               $call
             end)
    the_args = code.args
    for next_type in rest_types
        clause = :(if $arg isa $next_type # use `if` so this parses, then change to `elseif`
                     $call
                   end)
        clause.head = :elseif
        push!(the_args, clause)
        the_args = clause.args
    end
    push!(the_args, call) # The last one uses Julia's dispatch system.
    return code
end


"""
    @unionsplit(types, call)

Dispatch `call` "manually" on each of the `Tuple` of types `types`.
If `call` occurs in a place where the type of it's argument is not
known at compile time, `@unionsplit` may be faster than relying on
multiple dispatch.

# Example
```julia
for y in x
    @unionsplit((Int, Float64), func(y))
end
```
"""
macro unionsplit(types, call)
    quote
        $(esc(_unionsplit(types, call)))
    end
end

end # module ManualDispatch
