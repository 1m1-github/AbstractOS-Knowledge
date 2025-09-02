import Pkg
Pkg.add(["HTTP"])
using HTTP

const HTTP_IP = "127.0.0.1"
const HTTP_PORT = 8080

const HTMLCode = String
mutable struct MultiPathBrowserOutput <: OutputDevice 
    html_paths::Dict{String, HTMLCode}
end
output_devices[:MultiPathBrowserOutput] = MultiPathBrowserOutput(Dict("/" => "<html><body>Welcome to MultiPathBrowserOutput</body></html>"))

"""MultiPathBrowserOutput <: OutputDevice serves HTML content on different paths at http://$HTTP_IP:$HTTP_PORT/<path>. Use `put!(::MultiPathBrowserOutput, path::String, html::String)` to update the served HTML for a specific path. The root path `/` is also always updated no matter what the path was, as a default for the latest update."""
@api put!(device::MultiPathBrowserOutput, path::String, html::String) = device.html_paths[path] = device.html_paths["/"] = html

function handle_multi_path_http_request(req)
    path = req.target
    device = output_devices[:MultiPathBrowserOutput]
    if haskey(device.html_paths, path)
        headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
        HTTP.Response(200, headers, device.html_paths[path])
    else
        HTTP.Response(404, "404 Not Found: Path '$path' not found")
    end
end

@async HTTP.serve(handle_multi_path_http_request, HTTP_IP, HTTP_PORT)
