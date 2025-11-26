import Pkg
Pkg.add(["HTTP", "JSON"])
using HTTP, JSON

const X_AI_API_KEY = ENV["X_AI_API_KEY"]
# X_AI_MAX_OUTPUT_TOKENS = 100000

"""
intelligence connects to X AI
you can use `intelligence` directly if you ever need to. `complexity` is passed as model (grok-code-fast-1,grok-4-fast-reasoning,grok-4-fast-non-reasoning,grok-4-0709), unless it is a `Number`, in which case we translated to a model
"""
function intelligence(who, what_system, what_user, complexity)::String
    messages = [Dict("role" => "system", "content" => what_system)]
    push!(messages, Dict("role" => "user", "content" => what_user))

    url = "https://api.x.ai/v1/chat/completions"

    headers = [
        "Authorization" => "Bearer $X_AI_API_KEY",
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
        # "max_tokens" => X_AI_MAX_OUTPUT_TOKENS,
        "temperature" => 0.2,
    )

    response = HTTP.post(url, headers, JSON.json(body))
    result = JSON.parse(String(response.body))
    code = result["choices"][1]["message"]["content"]
    
    code = remove_prepend(code, """```julia""")
    code = remove_prepend(code, """```""")

    code 
end

function remove_prepend(code, prepend)
    postpend = """```"""
    if startswith(code, prepend) && endswith(code, postpend)
        code = code[length(prepend) + 1:end-length(postpend)]
        code = strip(code)
    end
    code
end

