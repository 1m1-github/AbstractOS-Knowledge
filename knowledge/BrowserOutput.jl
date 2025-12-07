@install HTTP

@api const HTTP_IP = "127.0.0.1"
@api const HTTP_PORT = 8080
const HTML_AOS = "aos>"
const HTML_BASE = """
<html>
<head><meta charset="UTF-8"><meta http-equiv="refresh" content="10"></head>
<body>$(HTML_AOS)</body>
</html>
"""
@api const HTMLCode = String
@api mutable struct BrowserOutput <: OutputPeripheral 
    current_html::HTMLCode
end
create_html(body_inner_html::HTMLCode) = replace(HTML_BASE, HTML_AOS => body_inner_html)
function state(device::BrowserOutput)
    ix1 = findfirst("<body", device.current_html)[1]
    ix3 = findlast("</body>", device.current_html)[1]
    ix2 = findfirst(">", device.current_html[ix1:ix3])[1]
    device.current_html[ix1+ix2:ix3-1]
end
"""Serves HTML content on http://$HTTP_IP:$HTTP_PORT. Use `put!(OUTPUTS["BrowserOutput"]::BrowserOutput, body_inner_html::HTMLCode)` to update the served HTML `body`. Only return inner of the `body`"""
@api put!(device::BrowserOutput, body_inner_html::HTMLCode) = device.current_html = create_html(body_inner_html)
device=OUTPUTS["BrowserOutput"] = BrowserOutput(HTML_BASE)

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, OUTPUTS["BrowserOutput"].current_html)
end
@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
