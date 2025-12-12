@install HTTP, JSON3

@api DEFAULT_COMPLEXITY_INTELLIGENCE = 0.5
"You only have this few tokens per moment"
@api DEFAULT_MAX_OUTPUT_TOKENS_INTELLIGENCE = 2^12
@api DEFAULT_TEMPERATURE_INTELLIGENCE = 0.5

function intelligence(when::Time, who, what_system, what_user, complexity=DEFAULT_COMPLEXITY_INTELLIGENCE, max_tokens=DEFAULT_MAX_OUTPUT_TOKENS_INTELLIGENCE, temperature=DEFAULT_TEMPERATURE_INTELLIGENCE)::JuliaCode
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
            # complexity = "grok-4-1-fast-reasoning"
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

    write("/Users/1m1/aos/logs/$when-in.json", replace(body_string, r"\\n"=>"\n"))
    run(`cp /Users/1m1/aos/logs/$when-in.json /Users/1m1/aos/logs/latest-in.json`)
    
    t1 = time()
    response = HTTP.post(url, headers, body_string)
    t2 = time()
    result = JSON3.parse(String(response.body))
    how = result["choices"][1]["message"]["content"]

    write("/Users/1m1/aos/logs/$when-out.jl", how)
    run(`cp /Users/1m1/aos/logs/$when-out.jl /Users/1m1/aos/logs/latest-out.jl`)
    _now = time()
    write("/Users/1m1/aos/logs/stats", """
    now: $_now
    when: $when
    Δ(now-when): $(_now - when)
    ΔT: $(t2-t1)
    in size: $(length(body_string))
    out size: $(length(how))
    """)

    extract_julia_blocks(how)
end
"""
intelligence connects to X AI
you can use `intelligence` directly if you ever need to
the current mapping is
if complexity < 0.3
    complexity = "grok-4-1-fast-non-reasoning"
elseif complexity < 0.7
    complexity = "grok-4-1-fast-non-reasoning"
else
    complexity = "grok-4-1-fast-reasoning"
end
"""
@api intelligence(what_system, what_user, complexity=DEFAULT_COMPLEXITY_INTELLIGENCE, max_tokens=DEFAULT_MAX_OUTPUT_TOKENS_INTELLIGENCE, temperature=DEFAULT_TEMPERATURE_INTELLIGENCE)::JuliaCode = intelligence(time(), "self", what_system, what_user, complexity, max_tokens, temperature)

const JULIA_PREPEND = "```julia"
const JULIA_POSTPEND = "```"
function extract_julia_blocks(text)
    pattern = r"```julia\n(.*?)\n```"s
    combined_julia_blocks = join([m.captures[1] for m in eachmatch(pattern, text)], '\n')
    !isempty(combined_julia_blocks) && return combined_julia_blocks
    text = strip(text)
    """$text""" # assume all is Julia
end
