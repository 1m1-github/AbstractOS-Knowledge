"will cause an InterruptException in the task given the task_name"
@api stop_task(task_name::Symbol) = schedule(tasks[task_name].task, InterruptException(), error=true)

"will `delete!` done or failed tasks"
@api function clean_tasks()
    global tasks
    for (task_name, task_element) in tasks
        task = task_element.task
        !istaskdone(task) && !istaskfailed(task) && continue
        delete!(tasks, task_name)
    end
end
