@install HTTP, JSON

"""
intelligence connects to X AI
you can use `intelligence` directly if you ever need to
the current mapping is
if complexity < 0.3
    complexity = "grok-4-1-fast-non-reasoning"
elseif complexity < 0.7
    complexity = "grok-4-1-fast-reasoning"
else
    complexity = "grok-4-1-fast-reasoning"
end
"""
@api function intelligence(who, what_system, what_user, complexity=0.5, max_tokens=1000000, temperature=0.2)::JuliaCode
    messages = [Dict("role" => "system", "content" => what_system)]
    push!(messages, Dict("role" => "user", "content" => what_user))

    url = "https://api.x.ai/v1/chat/completions"

    headers = [
        "Authorization" => """Bearer $(ENV["X_AI_API_KEY"])""",
        "Content-Type" => "application/json"
    ]

    if isa(complexity, Number)
        if complexity < 0.3
            complexity = "grok-4-1-fast-non-reasoning"
        elseif complexity < 0.7
            complexity = "grok-4-1-fast-reasoning"
        else
            complexity = "grok-4-1-fast-reasoning"
        end
    end

    body = Dict(
        "model" => complexity,
        "stream" => false,
        "messages" => messages,
        "temperature" => temperature,
        "max_tokens" => max_tokens,
    )

    response = HTTP.post(url, headers, JSON.json(body))
    result = JSON.parse(String(response.body))
    how = result["choices"][1]["message"]["content"]
    
    how = remove_prepend(how, """```julia""")
    remove_prepend(how, """```""")
end

function remove_prepend(how, prepend)
    postpend = """```"""
    if startswith(how, prepend) && endswith(how, postpend)
        how = how[length(prepend) + 1:end-length(postpend)]
        how = strip(how)
    end
    how
end
