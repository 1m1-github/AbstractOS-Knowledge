@install HTTP

@api const HTTP_IP = "127.0.0.1"
@api const HTTP_PORT = 8080

@api const HTMLCode = String
@api mutable struct BrowserOutput <: OutputPeripheral 
    current_html::HTMLCode
end
create_html(body_inner_html::HTMLCode) = """<html><meta charset="UTF-8"><body>$(body_inner_html)</body></html>"""
OUTPUTS["BrowserOutput"] = BrowserOutput(create_html("aos>"))
state(device::BrowserOutput) = device.current_html

"""Serves HTML content on http://$HTTP_IP:$HTTP_PORT. Use `put!(OUTPUTS["BrowserOutput"]::BrowserOutput, body_inner_html::HTMLCode)` to update the served HTML `body`. Only return inner of the `body`"""
@api put!(device::BrowserOutput, body_inner_html::HTMLCode) = device.current_html = create_html(body_inner_html)

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, OUTPUTS["BrowserOutput"].current_html)
end

@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
