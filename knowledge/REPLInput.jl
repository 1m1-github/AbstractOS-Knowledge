struct REPLInput <: InputDevice end

@api take!(::REPLInput) = nothing

INPUT_DEVICES[:REPL] = REPLInput()

function repl_parse(s::String)
    # @show "repl_parse", s, length(s) # DEBUG
    # @show strip(s), length(strip(s)) # DEBUG

    # todo lock?
    next(INPUT_DEVICES[:REPL], string(strip(s)))

    return
end