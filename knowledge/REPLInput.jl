struct REPLInput <: InputPeripheral end

@api take!(::REPLInput) = nothing

INPUTS["REPL"] = REPLInput()

function repl_parse(s::String)
    # todo lock?
    next(INPUTS["REPL"], string(strip(s)))
    return
end