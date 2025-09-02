import Pkg
Pkg.add(["HTTP"])
using HTTP

const HTTP_IP = "127.0.0.1"
const HTTP_PORT = 8080

const HTMLCode = String
mutable struct BrowserOutput <: OutputDevice 
    current_html::HTMLCode
end
output_devices[:BrowserOutput] = BrowserOutput("""<html><body>1M1</body></html>""")

"""BrowserOutput <: OutputDevice serves HTML content on http://$HTTP_IP:$HTTP_PORT. Use `put!(::BrowserOutput, html::String)` to update the served HTML."""
@api put!(device::BrowserOutput, html::String) = device.current_html = html

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, output_devices[:BrowserOutput].current_html)
end

@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
