struct REPLInput <: InputDevice end

@api take!(::REPLInput) = nothing

STATES[UUID(0)].input_devices[:REPL] = REPLInput()

function repl_parse(s::String)
    # @show "repl_parse", s, length(s) # DEBUG
    # @show strip(s), length(strip(s)) # DEBUG
    state = STATES[UUID(0)]
    device = state.input_devices[:REPL]

    # todo lock?
    next(state, device, string(strip(s)))

    return
end