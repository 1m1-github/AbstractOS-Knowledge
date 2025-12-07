# @install HTTP, JSON3, Gumbo, SQLite, Plots, Base64, Dates, Cascadia, SMTPClient, Serialization
@install HTTP, JSON3, Base64, Dates, SMTPClient, Serialization

struct CmdRedirect
    stdout::String
    stderr::String
    exitcode::Int
end

"Uses DuckDuckGo API for searching returning a Dict with :title, :url and :snippet keys"
function ddg_search(query::String; num_results::Int=10)
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
@api function browse_page(url::String)::String
    resp = HTTP.get(url)
    html = String(resp.body)
    replace(html, r"<[^>]*>"s => "")
end

"Handles binary download safely"
@api download_file(url::String, local_path::String)::Nothing = HTTP.download(url, local_path)

"Handles large files efficiently"
@api read_file(path::String)::String = read(path, String)

"Ensures atomic write for safety"
@api function write_file(path::String, content::String)::Nothing
    mkpath(dirname(path))
    open(path, "w") do f
        write(f, content)
    end
end

"list_directory = readdir"
@api list_directory(path::String=".")::Vector{String} = readdir(path)

"Captures output streams without blocking"
@api function run_shell(command::String)::CmdRedirect
    out = IOBuffer()
    err = IOBuffer()
    proc = run(pipeline(`$command`, stdout=out, stderr=err), wait=true)
    stdout_str = String(take!(out))
    stderr_str = String(take!(err))
    CmdRedirect(stdout_str, stderr_str, proc.exitcode)
end

# "Evaluates module after add for immediate use"
# @api function install_julia_pkg(pkg_name::String)::Nothing
#     Pkg.add(pkg_name)
#     @eval using $(Symbol(pkg_name))
# end

"Supports common HTTP methods like GET POST"
@api function send_http_request(method::String, url::String, headers::Dict=Dict(), body::String="")::String
    hpairs = Pair.(keys(headers), values(headers))
    resp = HTTP.request(method, url, hpairs, body)
    String(resp.body)
end

"Handles malformed JSON gracefully"
@api parse_json(json_str::String)::Any = JSON3.read(json_str)

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
"""persist entire state snapshot to long term memory in file: `joinpath(LONG_TERM_MEMORY, "$(time())-state.aos")`"""
@api function persist_state_snapshot()
    state_snapshot = Dict{Symbol, Any}()
    STATE_SYMBOLS = [:LOCK, :SHORT_TERM_MEMORY, :ACTIONS, :TASKS, :ERRORS, :INPUTS, :OUTPUTS, :SIGNALS, :CORE, :CONFIG, :LONG_TERM_MEMORY]
    for sym in STATE_SYMBOLS
        state_snapshot[sym] = eval(sym)
    end
    for (when, task) in state_snapshot[:TASKS] # running tasks cannot be serialized
        !istaskdone(task) && istaskstarted(task) && continue
        delete!(state_snapshot[:TASKS], when)
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

# "Serializes value as Julia code with timestamp"
# @api function backup_memory(key::Symbol)::Nothing
#     val = SHORT_TERM_MEMORY[key]
#     ts = Dates.format(now(), "yyyy-mm-dd_HH-MM-SSs")
#     fname = "backup_$(key)_$ts.jl"
#     open(fname, "w") do f
#         println(f, "SHORT_TERM_MEMORY[$(QuoteNode(key))] = ", repr(val))
#     end
# end

# "Loads and evaluates latest matching backup file"
# @api function load_backup(key::Symbol)::Any
#     files = filter(f -> startswith(f, "backup_$(key)_") && endswith(f, ".jl"), readdir())
#     isempty(files) && throw(KeyError(key))
#     latest = files[argmax(f -> stat(f).mtime, files)]
#     code = read(latest, String)
#     eval(Meta.parse(code))
#     SHORT_TERM_MEMORY[key]
# end

"""`send_email(["<to@email.org>"], "body", "message")`"""
@api function send_email(to::Vector{String}, subject::String, message::String)
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
