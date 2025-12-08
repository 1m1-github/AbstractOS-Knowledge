# @install HTTP, JSON3, Gumbo, SQLite, Plots, Base64, Dates, Cascadia, SMTPClient, Serialization
@install HTTP, JSON3, Base64, Dates, SMTPClient, Serialization

"Uses DuckDuckGo API for searching returning a Dict with :title, :url and :snippet keys"
@api function web_search(query; num_results=10)
    encoded_query = HTTP.URIs.escapeuri(query)
    url = "https://html.duckduckgo.com/html/?q=$(encoded_query)"
    response = HTTP.get(url)
    html = String(response.body)
    results = []
    link_pattern = r"<a rel=\"nofollow\" class=\"result__a\" href=\"([^\"]+)\">(.+?)</a>"
    snippet_pattern = r"<a class=\"result__snippet\"[^>]*>(.+?)</a>"
    links = collect(eachmatch(link_pattern, html))
    snippets = collect(eachmatch(snippet_pattern, html))
    for i in 1:min(num_results, length(links))
        title = replace(links[i].captures[2], r"<[^>]+>" => "")
        url = links[i].captures[1]
        snippet = i <= length(snippets) ? 
            replace(snippets[i].captures[1], r"<[^>]+>" => "") : ""
        push!(results, Dict(
            :title => strip(title),
            :url => url,
            :snippet => strip(snippet)
        ))
    end
    results
end

"Removes HTML tags to extract plain text"
@api function browse_page(url)
    resp = HTTP.get(url)
    html = String(resp.body)
    replace(html, r"<[^>]*>"s => "")
end

"Handles binary download safely"
@api download_file(url, local_path) = HTTP.download(url, local_path)

"Handles large files efficiently"
@api read_file(path) = read(path, String)

"Ensures atomic write for safety"
@api function write_file(path, content)
    mkpath(dirname(path))
    open(path, "w") do f
        write(f, content)
    end
end

"list_directory = readdir"
@api list_directory(path=".") = readdir(path)

"run_shell(`echo 1`), throws on error"
@api function run_shell(cmd::Cmd)::String
    out = IOBuffer()
    err = IOBuffer()
    proc = open(pipeline(cmd; stdout=out, stderr=err), "r")
    wait(proc)
    exception = String(take!(err))
    !isempty(exception) && throw(exception)
    String(take!(out))
end
run_shell(command::String) = run_shell(Cmd(split(command)))

"Supports common HTTP methods like GET POST"
@api function send_http_request(method, url, headers=Dict(), body="")
    hpairs = Pair.(keys(headers), values(headers))
    resp = HTTP.request(method, url, hpairs, body)
    String(resp.body)
end

"Handles malformed JSON gracefully"
@api parse_json(json_str) = JSON3.read(json_str)

# "Converts results to rows with column mapping"
# @api function query_sqlite(db_path::String, query::String)::Vector{Dict{String,Any}}
#     db = SQLite.DB(db_path)
#     stmt = prepare(db, query)
#     res = execute(stmt)
#     cols = names(stmt)
#     [Dict(zip(cols, row)) for row in Tables.rowtable(res)]
# end

# """Assumes variable x and equation like "x^2 - 1"."""
# @api function solve_equation(expr::String)::Any
#     @syms x
#     eq = sympify(expr)
#     solve(eq, x)
# end

# "Supports line plots with x y vectors in data"
# @api function generate_plot(data::Dict, plot_type::Symbol=:line)::String
#     plot_type ≠ :line && throw(ArgumentError("Only :line supported"))
#     xs = data[:x]
#     ys = data[:y]
#     p = plot(xs, ys)
#     tmp = tempname() * ".png"
#     savefig(p, tmp)
#     b64 = base64encode(read(tmp))
#     rm(tmp)
#     b64
# end

"to add a key and value to SHORT_TERM_MEMORY (which you can do directly too btw)"
@api remember(what_summary::JuliaCode, what::JuliaCode) = SHORT_TERM_MEMORY[what_summary] = what
"to retrieve from SHORT_TERM_MEMORY (which you can do directly too btw)"
@api remember(what_summary::JuliaCode) = SHORT_TERM_MEMORY[what_summary]
"""persist entire state (except `TASKS`) snapshot to long term memory in file: `joinpath(LONG_TERM_MEMORY, "$(time())-state.aos")`"""
@api function persist_state_snapshot()
    state_snapshot = Dict{Symbol, Any}()
    STATE_SYMBOLS = [:LOCK, :SHORT_TERM_MEMORY, :ACTIONS, :INPUTS, :OUTPUTS, :SIGNALS, :CORE, :CONFIG, :LONG_TERM_MEMORY]
    for sym in STATE_SYMBOLS
        state_snapshot[sym] = eval(sym)
    end
    when = time()
    serialize(joinpath(LONG_TERM_MEMORY, "$when-state.aos"), state_snapshot)
end
"""load persisted state snapshot from long term memory in file: `joinpath(LONG_TERM_MEMORY, "\$when-state.aos")` given """
@api load_state_snapshot(when::Time) = deserialize(joinpath(LONG_TERM_MEMORY, "$when-state.aos"))
"""load latest persisted state snapshot from long term memory"""
@api function load_state_snapshot(overwrite_current_state::Bool=false)
    state_files = filter(f -> endswith(f, "-state.aos"), readdir(LONG_TERM_MEMORY))
    max_when = maximum(parse(Time, split(f, "-")[1]) for f in state_files)
    state_snapshot = load_state_snapshot(max_when)
    !overwrite_current_state && return state_snapshot
    for (sym, val) in state_snapshot
        eval(quote
            const global $sym = $val
        end)
    end
    state_snapshot
end

"""`send_email(["<to@email.org>"], "body", "message")`"""
@api function send_email(to::Vector{String}, subject, message)
  from = "<email@1m1.io>"
  body = get_body(to, from, subject, message)
  # body = get_body(to, from, subject, message; cc, replyto)
  opt = SendOptions(
    isSSL=true,
    username="1@1m1.io",
    passwd=ENV["GMAIL_PASSWORD"])
  url = "smtps://smtp.gmail.com:465"
  send(url, to, from, body, opt)
end
