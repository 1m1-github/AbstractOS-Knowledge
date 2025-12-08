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

"Will `delete!` (istaskdone && !istaskfailed) `TASKS` and the corresponding `ACTIONS`"
function clean_tasks_and_actions()
    keys_to_delete = filter(when -> istaskstarted(TASKS[when]) && istaskdone(TASKS[when]) && !istaskfailed(TASKS[when]), collect(keys(TASKS)))
    for when in keys_to_delete
        @info "delete!(TASKS, when)", when
        delete!(TASKS, when)
        @info "delete!(ACTIONS, when)", when
        delete!(ACTIONS, when)
        @info "delete!(, when)", when
    end
end

"will find the `Action` given `what_summary`, `nothing` if not existing"
@api function find_action(what_summary::JuliaCode)
    possible_action_times = sort(filter(when -> ACTIONS[when].what_summary == what_summary, collect(keys(ACTIONS))))
    isempty(possible_action_times) && return nothing
    ACTIONS[first(possible_action_times)]
end
