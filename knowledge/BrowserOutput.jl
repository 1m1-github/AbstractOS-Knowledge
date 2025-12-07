@install HTTP

@api const HTTP_IP = "0.0.0.0"
@api const HTTP_PORT = 8080
const HTML_HEAD = """<head><meta charset="UTF-8"><meta http-equiv="refresh" content="2"></head>"""
const HTML_BODY_INNER = "aos>"
const HTML_BODY = "<body>$(HTML_BODY_INNER)</body>"
const HTML_BASE = "<html>$(HTML_HEAD)$(HTML_BODY)</html>"
@api const HTMLCode = String
@api mutable struct BrowserOutput <: OutputPeripheral 
    current_html::HTMLCode
end
function state(device::BrowserOutput)
    ix1 = findfirst("<body", device.current_html)[1]
    ix3 = findlast("</body>", device.current_html)[1]
    ix2 = findfirst(">", device.current_html[ix1:ix3])[1]
    device.current_html[ix1+ix2:ix3-1]
end
create_html(bodyinner::HTMLCode) = replace(HTML_BASE, HTML_BODY_INNER => bodyinner)
"""Serves HTML content on http://$HTTP_IP:$HTTP_PORT. Use `put!(OUTPUTS["BrowserOutput"]::BrowserOutput, body_inner_html::HTMLCode)` to update the served HTML `body`. Only return inner of the `body`"""
@api put!(device::BrowserOutput, bodyinner::HTMLCode) = device.current_html = create_html(bodyinner)
OUTPUTS["BrowserOutput"] = BrowserOutput(create_html(HTML_BODY_INNER))

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, OUTPUTS["BrowserOutput"].current_html)
end
@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
