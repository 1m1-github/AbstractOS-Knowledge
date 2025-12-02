"will cause an InterruptException in the `task` given the `what_summary` of an `Action`"
@api function stop_action(what_summary::JuliaCode)
    action = find_action(what_summary)
    isnothing(action) && return
    schedule(action.task, InterruptException(), error=true)
end

"will `delete!` done or failed actions"
@api function clean_actions()
    global ACTIONS
    for (when, action) in ACTIONS
        task = action.task
        !istaskdone(task) && !istaskfailed(task) && continue
        delete!(ACTIONS, when)
    end
end

function find_action(what_summary::JuliaCode)
    possible_action_times = sort(filter(when -> ACTIONS[when].what_summary == what_summary, collect(keys(ACTIONS))))
    isempty(possible_action_times) && return nothing
    ACTIONS[first(possible_action_times)]
end
