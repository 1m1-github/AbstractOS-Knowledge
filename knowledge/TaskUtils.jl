"will cause an InterruptException in the task given the task_name"
@api stop_task(task_name::Symbol) = schedule(tasks[task_name][end], InterruptException(), error=true)

function clean_tasks()
    global tasks
    for (task_name, task) in tasks
        !istaskdone(task) && !istaskfailed(task) && continue
        delete!(tasks, task_name)
    end
end

function run_task(device_output::String, code_string::String)
    code_expression = Meta.parse("begin $code_string end")
    task_name = taskname(code_expression)
    code_imports, code_body = separate(code_expression)
    run_task(device_output, task_name, code_string, code_imports, code_body)
end
