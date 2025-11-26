import REPL

struct REPLOutput <: OutputDevice end

"""
this knowledge allows you to communicate with the user on the REPL.
Use `put!(output_devices[:REPL], v::String)` to print a `String` to `stdout`, displayed on the main `REPL`
"""
@api put!(::REPLOutput, v::String) = println(stdout, v)

STATES[UUID(0)].output_devices[:REPL] = REPLOutput()

term = REPL.Terminals.TTYTerminal("AbstractOS", stdin, stdout, stderr)
repl = REPL.LineEditREPL(term, true)
# @async REPL.run_repl(repl) # this way, initrepld does not find active_repl
REPL.run_repl(repl) # this way blocks and we do not run `learn(:REPLInput); next(STATES[UUID(0)])`
