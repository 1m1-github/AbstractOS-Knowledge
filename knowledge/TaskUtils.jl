"will cause an InterruptException in the task given the task_name"
@api stop_task(task_name::Symbol) = schedule(TASKS[task_name].task, InterruptException(), error=true)

"will `delete!` done or failed tasks"
@api function clean_tasks()
    global TASKS
    for (task_name, task_element) in TASKS
        task = task_element.task
        !istaskdone(task) && !istaskfailed(task) && continue
        delete!(TASKS, task_name)
    end
end

@api function create_task()
    
end