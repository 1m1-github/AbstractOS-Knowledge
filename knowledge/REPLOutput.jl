import REPL

struct REPLOutput <: OutputDevice end

"""
this knowledge allows you to communicate with the user on the REPL.
Use `put!(OUTPUT_DEVICES[:REPL], v::String)` to print a `String` to `stdout`, displayed on the main `REPL`
"""
@api put!(::REPLOutput, v::String) = println(stdout, v)

OUTPUT_DEVICES[:REPL] = REPLOutput()
