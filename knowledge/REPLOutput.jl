import REPL

struct REPLOutput <: OutputPeripheral end

"""
this knowledge allows you to communicate with the user on the REPL.
Use `put!(OUTPUTS["REPL"], v::String)` to print a `String` to `stdout`, displayed on the main `REPL`
"""
@api put!(::REPLOutput, v::String) = println(stdout, v)

OUTPUTS["REPL"] = REPLOutput()
