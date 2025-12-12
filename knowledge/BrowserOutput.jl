@install HTTP

@api const HTTP_IP = "0.0.0.0"
@api const HTTP_PORT = 8080
const HTML_HEAD = """
<head>
<meta charset="UTF-8">
<meta http-equiv="refresh" content="2">
</head>
"""
const HTML_BODY_INNER = "aos>"
const HTML_BODY = "<body>$(HTML_BODY_INNER)</body>"
const HTML_BASE = "<html>$(HTML_HEAD)$(HTML_BODY)</html>"
"Serves HTML on http://$HTTP_IP:$HTTP_PORT"
@api mutable struct BrowserOutput <: OutputPeripheral 
    current_html::String
end
function state(::BrowserOutput)
    device = OUTPUTS["BrowserOutput"]
    ix1 = findfirst("<body", device.current_html)[1]
    ix3 = findlast("</body>", device.current_html)[1]
    ix2 = findfirst(">", device.current_html[ix1:ix3])[1]
    """"$(device.current_html[ix1+ix2:ix3-1])\""""
end
create_html(body_inner::String) = replace(HTML_BASE, HTML_BODY_INNER => body_inner)
"""
Overwrites the inner of the `body` of the HTML, use mainly this to communicate with me
"""
@api put!(::BrowserOutput, body_inner::String) = OUTPUTS["BrowserOutput"].current_html = create_html(body_inner)

# """
# You can display beautifully using typst, for math or anything
# """
# @api function put_typst!(::BrowserOutput, typst_code::String)
#     escaped = replace(typst_code, "`" => "\\`")
#     script = """
#     <script type="module">
#       import {init,svg} from "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-all-in-one.ts@0.6.0/dist/esm/index.js";
#       await init();
#       const src = `$escaped`;
#       const {svg:html} = await svg({mainContent:src});
#       body.innerHTML = html;
#     </script>
#     """
#     new_html = replace(
#         OUTPUTS["BrowserOutput"].current_html,
#         r"(?i)</head>" => script * "</head>"
#     )
#     OUTPUTS["BrowserOutput"].current_html = new_html
#     # typst_code = """
#     # \$typst.svg({mainContent:$typst_code}).then(svg=>{body.innerHTML=svg});
#     # """
#     # put!(OUTPUTS["BrowserOutput"], typst_code)
# end

OUTPUTS["BrowserOutput"] = BrowserOutput(create_html(HTML_BODY_INNER))

function handle_http_request(req)
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, OUTPUTS["BrowserOutput"].current_html)
end
@async HTTP.serve(handle_http_request, HTTP_IP, HTTP_PORT)
