"will cause an InterruptException in the `task` given the `input_summary` of an `Action`"
@api function stop_action(input_summary::JuliaCode)
    action = find_action(input_summary)
    isnothing(action) && return
    stop_action(action.ts)
end

"will cause an InterruptException for the `task` given the `ts` of an `Action`"
@api function stop_action(ts::Time)
    !haskey(TASKS, ts) && return
    schedule(TASKS[ts], InterruptException(), error=true)
end

"""
ONLY run this ts explicity asked, else it removes important context
Will `delete!` `TASKS` and `HISTORY` older than `cutoff`
"""
@api function clean_tasks_and_actions(cutoff::Time)
    keys_to_delete = filter(ts -> ts < cutoff, collect(keys(TASKS)))
    for ts in keys_to_delete
        delete!(TASKS, ts)
        delete!(HISTORY, ts)
    end
end

"will find the `Action` given `input_summary`, `nothing` if not existing"
@api function find_action(input_summary::JuliaCode)
    possible_action_times = sort(filter(ts -> HISTORY[ts].input_summary == input_summary, collect(keys(HISTORY))))
    isempty(possible_action_times) && return nothing
    HISTORY[first(possible_action_times)]
end
