struct REPLInput <: InputPeripheral end
take!(::REPLInput) = nothing
INPUTS["REPL"] = REPLInput()
