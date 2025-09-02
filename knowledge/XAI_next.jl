import Pkg
Pkg.add(["HTTP", "JSON"])
using HTTP, JSON

const X_AI_API_KEY = "" # needs to be set

X_AI_MAX_OUTPUT_TOKENS = 100000
X_AI_MODEL = "grok-code-fast-1"
# @api X_AI_MODEL = "grok-4"

"""
next connects to X AI
you can use `next` directly if you ever need to
"""
function next(;system::String, user::String)::String
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

    input_logfile = file_stream("input.jl") # DEBUG
    write(input_logfile, "$system\n$user") # DEBUG
    close(input_logfile) # DEBUG

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

