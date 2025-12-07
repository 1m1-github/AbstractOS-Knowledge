"will cause an InterruptException in the `task` given the `what_summary` of an `Action`"
@api function stop_action(what_summary::JuliaCode)
    action = find_action(what_summary)
    isnothing(action) && return
    stop_action(action.when)
end

"will cause an InterruptException for the `task` given the `when` of an `Action`"
@api function stop_action(when::Time)
    !haskey(TASKS, when) && return
    schedule(TASKS[when], InterruptException(), error=true)
end

"Will `delete!` done or failed `TASKS` and the corresponding `ACTIONS` and `ERRORS`"
@api function clean_actions_and_errors()
    for (when, task) in ACTIONS
        !istaskdone(task) && !istaskfailed(task) && continue
        haskey(ACTIONS, when) && delete!(ACTIONS, when)
        haskey(ERRORS, when) && delete!(ERRORS, when)
    end
end

"will find the `Action` given `what_summary`, `nothing` if not existing"
@api function find_action(what_summary::JuliaCode)
    possible_action_times = sort(filter(when -> ACTIONS[when].what_summary == what_summary, collect(keys(ACTIONS))))
    isempty(possible_action_times) && return nothing
    ACTIONS[first(possible_action_times)]
end
"will find the `Action` given `when`, `nothing` if not existing"
@api find_action(when::Time) = get(ACTIONS, when, nothing)
