@install HTTP, JSON3

function intelligence(when::Time, who, what_system, what_user, complexity=0.5, max_tokens=2^12, temperature=0.0)::JuliaCode
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
            complexity = "grok-4-1-fast-non-reasoning"
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
    body_string = JSON3.write(body)

    write("/Users/1m1/aos/logs/$when-in.json", body_string)

    response = HTTP.post(url, headers, body_string)
    result = JSON3.parse(String(response.body))
    how = result["choices"][1]["message"]["content"]

    write("/Users/1m1/aos/logs/$when-out.jl", how)

    extract_julia_blocks(how)
end
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
@api intelligence(what_system, what_user, complexity=0.5, max_tokens=2^12, temperature=0.0)::JuliaCode = intelligence(time(), "self", what_system, what_user, complexity, max_tokens, temperature)

function extract_julia_blocks(text)
    pattern = r"```julia\n(.*?)\n```"s
    join([m.captures[1] for m in eachmatch(pattern, text)], '\n')
end
