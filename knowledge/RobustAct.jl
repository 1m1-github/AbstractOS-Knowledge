function act(who::Any, what::JuliaCode, how::JuliaCode)
    @info "act", who, what, how
    when = time()
    # Pre-create minimal Action with task (will update summaries if possible)
    task = Threads.@spawn begin
        local what_summary = "parse pending"
        local how_summary = "parse pending"
        try
            how_expression = get_how_expression(how)
            what_summary = extract_summary(how_expression, what, :what_summary)
            how_summary = extract_summary(how_expression, how, :how_summary)
            # Update Action with summaries
            if haskey(ACTIONS, when)
                old_action = ACTIONS[when]
                ACTIONS[when] = Action(old_action.when, old_action.who, what_summary, old_action.what, how_summary, old_action.what, old_action.task)
            end
            how_imports, how_body = separate(how_expression)
            eval(how_imports)
            eval(how_body)
            what_summary, how_summary  # Return for potential use
        catch e
            # Ensure Action exists with failure indicators
            if !haskey(ACTIONS, when)
                ACTIONS[when] = Action(when, who, "parse/exec failed: $(summary(what))", what, "parse/exec failed: $(summary(how))", how, task)
            else
                old_action = ACTIONS[when]
                ACTIONS[when] = Action(old_action.when, old_action.who, "parse/exec failed: $(old_action.what_summary)", what, "parse/exec failed: $(old_action.how_summary)", how, old_action.task)
            end
            ERRORS[when] = e
            rethrow()  # Ensure task is marked failed
        end
    end
    # Minimal Action immediately (updated inside task)
    ACTIONS[when] = Action(when, who, "init", what, "init", how, task)
    when
end

"short summary of code str"
summary(s::String) = length(s) > 50 ? first(split(s, r"[\.\n]")) * "..." : s
