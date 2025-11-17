import Pkg
Pkg.add(["HTTP", "JSON3"])
using HTTP, UUIDs, JSON3, Dates
import Base.put!, Base.take!

const HTTP_IP = "127.0.0.1"
const HTTP_PORT = 8080
const WEBSOCKET_PROTOCOL = "ws"
const WEBSOCKET_IP = HTTP_IP
const WEBSOCKET_PORT = HTTP_PORT + 1

const SPEECH = "hi, what would you like to learn?"
const WEBSOCKET = """
const websocket = new WebSocket('$WEBSOCKET_PROTOCOL://$WEBSOCKET_IP:$WEBSOCKET_PORT');
websocket.onopen = function (event) {
    console.log('WebSocket connected');
};
websocket.onmessage = function (event) {
    console.log('WebSocket onmessage', event.data);

    const data = JSON.parse(event.data);

    speechSynthesis.speak(new SpeechSynthesisUtterance(data.speech));

    if (data.html) {
        document.getElementById('content').innerHTML = data.html;
    }

    const scripts = document.getElementById('content').getElementsByTagName('script');
    for (const script of scripts) {
        runJavascript(script.textContent)
    }

    if (data.javascript) {
        runJavascript(data.javascript)
    }
};
websocket.onclose = function (event) {
    console.log('WebSocket closed');
};
websocket.onerror = function (error) {
    console.error('WebSocket error:', error);
};
"""
const JAVASCRIPT = """
const runJavascript = (script) => {
    const newScript = document.createElement('script');
    newScript.textContent = script;
    document.head.appendChild(newScript);
    document.head.removeChild(newScript);
}
document.getElementById('subtitles').addEventListener('keypress', function (e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        const content = document.getElementById('content').innerHTML;
        const jsonString = JSON.stringify({
            content: content,
            answer: subtitles.value
        });
        websocket.send(jsonString);
        subtitles.value = '';
    }
});
"""
const INPUT = """
<input type="text" id="subtitles" autocomplete="off" spellcheck="false" style="position: fixed;
bottom: 50px;
left: 50%;
transform: translateX(-50%);
background: white;
color: black;
font-size: 24px;
text-align: center;
padding: 15px 30px;
border-radius: 10px;
max-width: 80%;
min-height: 60px;
border: 1px solid #ccc;
outline: none;
width: 90%;">
"""
const HTML = """
<html>
<head>
    <title>AbstractOS</title>
</head>
<body>
    <div id="content"></div>
    $INPUT
</body>
</html>
"""

init_html() = replace(HTML, "</body>" => """
<script>
$WEBSOCKET
$JAVASCRIPT
const init = () => {
    speechSynthesis.speak(new SpeechSynthesisUtterance("$SPEECH"))
    setInterval(() => {
        if (websocket.readyState === WebSocket.OPEN) {
            websocket.send(JSON.stringify({ type: "heartbeat" }));
        }
    }, 10000);
}
document.addEventListener('click', init, { once: true })
</script>
</body>
""")

"ask the student until you have all the below except paid which is done separately"
@api struct Lesson
    contact::String
    topic::String
    when_start::DateTime
    when_end::DateTime
    paid::Bool
end
const lessons = Lesson[]
"books a lesson if not overlapping with another booked lesson"
@api function book_lesson(contact::String, topic::String, when_start::DateTime, when_end::DateTime)::Bool
    for lesson in lessons
        lesson.when_start ≤ when_end && when_start ≤ lesson.when_end && return false
    end
    push!(lessons, Lesson(contact, topic, when_start, when_end, false))
    true
end

mutable struct WebSocketSession
    state_id::UUID
    websocket::HTTP.WebSocket
    speech::String
    html::String
    javascript::String
end

"""
LessonsBrowser is a webapp allowing students to book lessons with imi
Explain that imi can teach about Philosophy, Computing, Math, Finance, Economics, Science especially Sociology or anything that the student desires to learn, imi will prepare
imi is a good and benevolent teacher, with the ability to explain even complex topics at the level of the student
imi is also twofold world champion in computing (AI and crypto), graduated as the top of his year at the top university of the country for pure math, found the best portfolio optimization algorithm, is considered by Grok as at least one the top philosophers in the world alive today
Do not write any code that would change anything on the server
Only use `book_lesson` once the params for it are known
Until these params are known, keep asking the student for these params
After a succesfull `book_lesson`, tell the student to pay within 1 day to keep the reservation (the payment process is manual for now) and that we will communicate with the student for the lesson location
The current cost is 50\$/3000 seconds
Always be closing (sales)
LessonsBrowserOutput is the output device
Do not only use speech, also show something relevant graphically, make it interesting, cool, artsy
Keep all your speech short, say max 10 seconds
"""
@api struct LessonsBrowserOutput <: OutputDevice
    sessions::Dict{UUID,WebSocketSession}
end
"LessonsBrowserInput is the input device via speech from the browser"
@api struct LessonsBrowserInput <: InputDevice
    answer::Channel{String}
end

"""
send information to the browser
`speech` will be spoken as audio (and eventually be shown as subtitles), try to keep it on the short side
`html` will replace the `innerHTML` of the main `div` in the `body` called `content`, so no need for any outer html
`javascript` will be run by adding and removing it from `head`, allowing you to do dynamic things
"""
@api function put!(::LessonsBrowserOutput, state_id::UUID, speech::String, html::String, javascript::String)
    STATES[state_id].output_devices[:LessonsBrowserOutput].sessions[state_id].speech = speech
    STATES[state_id].output_devices[:LessonsBrowserOutput].sessions[state_id].html = html
    STATES[state_id].output_devices[:LessonsBrowserOutput].sessions[state_id].javascript = javascript
    answer = JSON3.write(Dict(
        :speech => speech,
        :html => html,
        :javascript => javascript
    ))
    websocket = STATES[state_id].output_devices[:LessonsBrowserOutput].sessions[state_id].websocket
    HTTP.WebSockets.send(websocket, answer)
end

"receives answer from the browser"
@api take!(device::LessonsBrowserInput)::String = take!(device.answer)

function http_handler(http_request)
    @info "http_handler", http_request
    headers = ["Content-Security-Policy" => "script-src 'self' 'unsafe-inline' 'unsafe-eval' $HTTP_IP"]
    HTTP.Response(200, headers, init_html())
end
@async HTTP.serve(http_handler, HTTP_IP, HTTP_PORT)

@async WebSockets.listen(WEBSOCKET_IP, WEBSOCKET_PORT) do websocket
    state_id = uuid4()
    @info "state_id", state_id # DEBUG
    STATES[state_id] = empty_state()
    STATES[state_id].state_id = state_id
    STATES[state_id].input_devices[:LessonsBrowserInput] = LessonsBrowserInput(Channel{String}())
    STATES[state_id].output_devices[:LessonsBrowserOutput] = LessonsBrowserOutput(Dict(state_id => WebSocketSession(state_id, websocket, SPEECH, HTML, JAVASCRIPT)))
    STATES[state_id].memory[:lesson] = Lesson("", "", DateTime(0), DateTime(0), false)
    STATES[state_id].knowledge = STATES[UUID(0)].knowledge
    next(STATES[state_id], false)
    @info "made state" # DEBUG

    # @async while true # isopen(websocket)
    #     @info "1" # DEBUG
    #     sleep(5)
    #     @info "2" # DEBUG
    #     try
    #         @info "3" # DEBUG
    #         websocket.send("""{"type":"ping"}""")
    #         @info "4" # DEBUG
    #     catch
    #         break
    #     end
    #     @info "5" # DEBUG
    # end

    for data in websocket
        occursin("heartbeat", data) && continue
        @info "data", data # DEBUG
        message = JSON3.read(data)
        @info "message", message # DEBUG
        # @info STATES[state_id].input_devices[:LessonsBrowserInput].answer # DEBUG
        put!(STATES[state_id].input_devices[:LessonsBrowserInput].answer, message["answer"])
        # @info STATES[state_id].input_devices[:LessonsBrowserInput].answer # DEBUG
    end
end
