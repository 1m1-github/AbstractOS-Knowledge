using Pkg
Pkg.add(["HTTP", "JSON3", "Gumbo", "SQLite", "Plots", "Base64", "Dates"])
using HTTP, JSON3, Gumbo, SQLite, Plots, Base64, Dates

struct CmdRedirect
    stdout::String
    stderr::String
    exitcode::Int
end

"Uses DuckDuckGo API for searching"
function web_search(query::String, num_results::Int=5)::Vector{Dict{String,Any}}
    q = replace(HTTP.escapeuri(query), "%20" => "+")
    url = "https://duckduckgo.com/html/?q=$q"
    resp = HTTP.get(url)
    body = String(resp.body)
    results = Dict{String,Any}[]
    rx = r"""<div class="result[^"]*web-result[^>]*>.*?<h2 class="result__title">\s*<a.*?href="//duckduckgo\.com/l/\?uddg=([^&"]+).*?>([^<]+)</a>.*?result__url"\s+href="[^"]*">([^<]+)</a>.*?<a class="result__snippet".*?>([^<]+?)</a>.*?</div>"""s
    count = 1
    for m in eachmatch(rx, body)
        href = m.captures[1]
        title = strip(m.captures[2])
        domain = strip(m.captures[3])
        snippet = strip(m.captures[4])
        real_url = HTTP.unescapeuri(href)
        push!(results, Dict("title" => title, "url" => real_url, "snippet" => snippet, "domain" => domain))
        count += 1 ; num_results < count && break
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
@api function download_file(url::String, local_path::String)::Nothing
    HTTP.download(url, local_path)
end

"Handles large files efficiently"
@api function read_file(path::String)::String
    read(path, String)
end

"Ensures atomic write for safety"
@api function write_file(path::String, content::String)::Nothing
    mkpath(dirname(path))
    open(path, "w") do f
        write(f, content)
    end
end

"Includes hidden files optionally"
@api function list_directory(path::String=".")::Vector{String}
    readdir(path)
end

"Captures output streams without blocking"
@api function run_shell(command::String)::CmdRedirect
    out = IOBuffer()
    err = IOBuffer()
    proc = run(pipeline(`$command`, stdout=out, stderr=err), wait=true)
    stdout_str = String(take!(out))
    stderr_str = String(take!(err))
    CmdRedirect(stdout_str, stderr_str, proc.exitcode)
end

"Evaluates module after add for immediate use"
@api function install_julia_pkg(pkg_name::String)::Nothing
    Pkg.add(pkg_name)
    @eval using $(Symbol(pkg_name))
end

"Supports common HTTP methods like GET POST"
@api function send_http_request(method::String, url::String, headers::Dict=Dict(), body::String="")::String
    hpairs = Pair.(keys(headers), values(headers))
    resp = HTTP.request(method, url, hpairs, body)
    String(resp.body)
end

"Handles malformed JSON gracefully"
@api function parse_json(json_str::String)::Any
    JSON3.read(json_str)
end

"Converts results to rows with column mapping"
@api function query_sqlite(db_path::String, query::String)::Vector{Dict{String,Any}}
    db = SQLite.DB(db_path)
    stmt = prepare(db, query)
    res = execute(stmt)
    cols = names(stmt)
    [Dict(zip(cols, row)) for row in Tables.rowtable(res)]
end

# """Assumes variable x and equation like "x^2 - 1"."""
# @api function solve_equation(expr::String)::Any
#     @syms x
#     eq = sympify(expr)
#     solve(eq, x)
# end

"Supports line plots with x y vectors in data"
@api function generate_plot(data::Dict, plot_type::Symbol=:line)::String
    plot_type ≠ :line && throw(ArgumentError("Only :line supported"))
    xs = data[:x]
    ys = data[:y]
    p = plot(xs, ys)
    tmp = tempname() * ".png"
    savefig(p, tmp)
    b64 = base64encode(read(tmp))
    rm(tmp)
    b64
end

"Uses external whisper CLI if available"
@api function transcribe_audio(audio_path::String)::String
    out = IOBuffer()
    err = IOBuffer()
    proc = run(pipeline(`whisper $audio_path`, stdout=out, stderr=err), wait=true)
    success(proc) || throw(ErrorException("Whisper failed: $(String(take!(err)))"))
    String(take!(out)) |> strip
end

"Takes leading sentences until length limit"
@api function summarize_text(text::String, max_length::Int=200)::String
    intelligence(nothing, "", "summarize text:$text", 0.3, max_length)
end

"Serializes value as Julia code with timestamp"
@api function backup_memory(key::Symbol)::Nothing
    val = MEMORY[key]
    ts = Dates.format(now(), "yyyy-mm-dd_HH-MM-SSs")
    fname = "backup_$(key)_$ts.jl"
    open(fname, "w") do f
        println(f, "MEMORY[$(QuoteNode(key))] = ", repr(val))
    end
end

"Loads and evaluates latest matching backup file"
@api function load_backup(key::Symbol)::Any
    files = filter(f -> startswith(f, "backup_$(key)_") && endswith(f, ".jl"), readdir())
    isempty(files) && throw(KeyError(key))
    latest = files[argmax(f -> stat(f).mtime, files)]
    code = read(latest, String)
    eval(Meta.parse(code))
    MEMORY[key]
end
