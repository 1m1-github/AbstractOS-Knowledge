import Pkg
Pkg.add(["HTTP"])
using HTTP

const HTTP_IP = "127.0.0.1"
const HTTP_PORT = 8080

struct BrowserOutput <: OutputDevice end
output_devices[:BrowserOutput] = BrowserOutput()

current_html = """<html><body>1M1</body></html>"""

"""BrowserOutput <: OutputDevice serves HTML content on http://$HTTP_IP:$HTTP_PORT. Use `put!(device::BrowserOutput, html::String)` to update the served HTML."""
@api function put!(::BrowserOutput, html::String)
    global current_html
    current_html = html
end

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, current_html)
end

@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
