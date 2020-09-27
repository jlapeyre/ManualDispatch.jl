# ManualDispatch

Provides the macro `@unionsplit` to dispatch "manually" on types rather than
rely on runtime multiple dispatch.

If type information is hidden from the compiler, then the dispatch system has to select the
correct method at runtime, which can be very slow. In this case it can be much faster to use
conditional statements to check the type. Inside each branch of the conditional, the type
is known and the call can be devirtualized or inlined.

This macro is based on ideas of Tim Holy and Takafumi Arakaki.

### Example

In the following examples, using `@union_split` is much faster than relying on multiple dispatch,
which must happen at runtime.

```julia
using BenchmarkTools
using ManualDispatch

func(x::Int) = 1
func(x::Float64) = 1

# The type of the arrays is `Vector{Any}`, so that the compiler cannot choose the
# required method for `func` at compile time.
const x_int = Any[1 for i in 1:1000]
const x_float = Any[1.0 for i in 1:1000]
const x_mixed = Any[iseven(i) ? 1 : 1.0 for i in 1:1000]

function ex_union_split(x)
    for y in x
        @unionsplit((Int, Float64), func(y))
    end
end

function ex_runtime_dispatch(x)
    for y in x
        func(y)
    end
end

print("Manual union split with array of Int")
@btime ex_union_split(x_int)

print("Runtime dispatch with array of Int")
@btime ex_runtime_dispatch(x_int)

print("Manual union split with array of Float64")
@btime ex_union_split(x_float)

print("Runtime dispatch with array of Float64")
@btime ex_runtime_dispatch(x_float)

print("Manual union split with mixed array")
@btime ex_union_split(x_mixed)

print("Runtime dispatch with mixed array")
@btime ex_runtime_dispatch(x_mixed)
```
