using Pkg
Pkg.add("ReplMaker")
using ReplMaker

struct REPLInput <: InputDevice
    chan::Channel{String}
end
REPLInput() = REPLInput(Channel{String}(Inf))
take!(d::REPLInput) = take!(d.chan)

STATES[UUID(0)].input_devices[:REPL] = REPLInput()
next(STATES[UUID(0)], false)

function repl_parse(s::String)
    put!(STATES[UUID(0)].input_devices[:REPL].chan, s)
    nothing
end

initrepl(repl_parse,
         prompt_text="aos> ",
         prompt_color=:blue,
         start_key="\\C-a",
         mode_name="AOS_mode",
         valid_input_checker=complete_julia)

write(STDIN.buffer, "\x01")
