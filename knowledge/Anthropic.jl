@install HTTP, JSON3

@api DEFAULT_COMPLEXITY_INTELLIGENCE = 0.5
"You only have this few tokens per moment"
@api DEFAULT_MAX_OUTPUT_TOKENS_INTELLIGENCE = 2^8
@api DEFAULT_TEMPERATURE_INTELLIGENCE = 0.5

function intelligence(when::Time, who, what_system, what_user, complexity=DEFAULT_COMPLEXITY_INTELLIGENCE, max_tokens=DEFAULT_MAX_OUTPUT_TOKENS_INTELLIGENCE, temperature=DEFAULT_TEMPERATURE_INTELLIGENCE)::JuliaCode
    url = "https://api.anthropic.com/v1/messages"

    headers = [
        "x-api-key" => ENV["ANTHROPIC_API_KEY"],
        "anthropic-version" => "2023-06-01",
        "Content-Type" => "application/json"
    ]

    if isa(complexity, Number)
        if complexity < 0.3
            complexity = "claude-haiku-4-5-20251001"
        elseif complexity < 0.7
            complexity = "claude-sonnet-4-5-20250929"
        else
            complexity = "claude-opus-4-5-20251101"
        end
    end

    body = Dict(
        "model" => complexity,
        "system" => what_system,
        "messages" => [Dict("role" => "user", "content" => what_user)],
        "temperature" => temperature,
        "max_tokens" => max_tokens,
    )
    body_string = JSON3.write(body)

    write("/Users/1m1/aos/logs/$when-in.json", body_string)
    run(`cp /Users/1m1/aos/logs/$when-in.json /Users/1m1/aos/logs/latest-in.json`)

    response = HTTP.post(url, headers, body_string)
    result = JSON3.parse(String(response.body))
    how = result["content"][1]["text"]

    write("/Users/1m1/aos/logs/$when-out.jl", how)
    run(`cp /Users/1m1/aos/logs/$when-out.jl /Users/1m1/aos/logs/latest-out.jl`)

    extract_julia_blocks(how)
end
"""
intelligence connects to Anthropic Claude
you can use `intelligence` directly if you ever need to
the current mapping is
if complexity < 0.3
    complexity = "claude-haiku-4-5-20251001"
elseif complexity < 0.7
    complexity = "claude-sonnet-4-5-20250929"
else
    complexity = "claude-opus-4-5-20251101"
end
"""
@api intelligence(what_system, what_user, complexity=DEFAULT_COMPLEXITY_INTELLIGENCE, max_tokens=DEFAULT_MAX_TOKENS_INTELLIGENCE, temperature=DEFAULT_TEMPERATURE_INTELLIGENCE)::JuliaCode = intelligence(time(), "self", what_system, what_user, complexity, max_tokens, temperature)

function extract_julia_blocks(text)
    pattern = r"```julia\n(.*?)\n```"s
    combined_julia_blocks = join([m.captures[1] for m in eachmatch(pattern, text)], '\n')
    !isempty(combined_julia_blocks) && return combined_julia_blocks
    strip(text)
end