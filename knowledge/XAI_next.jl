import Pkg
Pkg.add(["HTTP", "JSON"])
using HTTP, JSON

const X_AI_API_KEY = "" # needs to be set

@api X_AI_MAX_OUTPUT_TOKENS = 10000
@api X_AI_MODEL = "grok-4"

"""
next connects to X AI
you can use `next` directly if you ever need to
"""
@api function next(;system::String, user::String)::String
    messages = [Dict("role" => "system", "content" => system)]
    push!(messages, Dict("role" => "user", "content" => user))

    url = "https://api.x.ai/v1/chat/completions"

    headers = [
        "Authorization" => "Bearer $X_AI_API_KEY",
        "Content-Type" => "application/json"
    ]

    body = Dict(
        "model" => X_AI_MODEL,
        "stream" => false,
        "messages" => messages,
        "max_tokens" => X_AI_MAX_OUTPUT_TOKENS,
        "temperature" => 0.2,
    )

    response = HTTP.post(url, headers, JSON.json(body))
    result = JSON.parse(String(response.body))
    code = result["choices"][1]["message"]["content"]
    
    julia_prepend = """```julia"""
    julia_postpend = """```"""
    if startswith(code, julia_prepend) && endswith(code, julia_postpend)
        code = code[length(julia_prepend) + 1:end-length(julia_postpend)]
        code = strip(code)
    end

    code 
end

