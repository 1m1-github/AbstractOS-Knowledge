@install PortAudio, SampledSignals, ZMQ, Serialization

include(joinpath(LONG_TERM_MEMORY, "Transcription.jl"))

"listens to audio received via ZMQ and `put!`s text"
struct AudioInput <: InputPeripheral
    speaker::String
    channel::Channel{String}
end
@api take!(a::AudioInput) = take!(a.channel)
put!(a::AudioInput, what) = put!(a.channel, what)

function clear_zmq(socket)
    while true
        try
            recv(socket, nowait=true)
        catch _
            break
        end
    end
end

mutable struct AudioData
    speaker::String
    buffer::Union{SampleBuf{Float32,2},Nothing}
    what::String
    when::Time
end

function get_audios_from_zmq(socket)
    message = ZMQ.recv(socket)
    @show typeof(message)
    deserialize(IOBuffer(message))
end

const ZMQ_CONTEXT = ZMQ.context()
const ZMQ_SOCKET = Socket(ZMQ_CONTEXT, PULL)
bind(ZMQ_SOCKET, "tcp://*:5555")
clear_zmq(ZMQ_SOCKET)
const LISTENING = Ref(true)
const CALLING_INTELLIGENCE = Ref(false)
function start_listening(speaker)
    INPUTS["AudioInput"] = AudioInput(speaker, Channel{JuliaCode}())
    @info "Listening on port 5555"
    @async while LISTENING[]
        yield()
        audios_data = get_audios_from_zmq(ZMQ_SOCKET)
        @sync for (_, audio_data) in audios_data
            isnothing(audio_data.buffer) && continue
            @async audio_data.what = transcribe(audio_data.buffer.data)
        end
        turn = []
        for (_, audio_data) in audios_data
            what = clean_whisper_text(audio_data.what)
            isempty(what) && continue
            when = audio_data.when
            speaker = audio_data.speaker
            push!(turn, "<$when>$speaker:$what")
        end
        isempty(turn) && continue
        conversation = join(turn, '\n')
        if CALLING_INTELLIGENCE[]
            @info "putting to audio", conversation
            @async put!(INPUTS["AudioInput"], conversation)
        end
    end
end

while get(SIGNALS, "awake", false)
    yield()
end
const AUDIO_INPUT_TASK = start_listening("imi")

# CALLING_INTELLIGENCE[] = true
# LISTENING[] = false
