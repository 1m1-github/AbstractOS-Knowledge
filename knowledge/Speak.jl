const ROOT_DIR = joinpath("/", "Users", "1m1", "aos")
cd(ROOT_DIR)

using Logging

struct Logger <: AbstractLogger
    console_logger::ConsoleLogger
    file_logger::SimpleLogger
end

Logging.min_enabled_level(logger::Logger) = min(Logging.min_enabled_level(logger.console_logger), Logging.min_enabled_level(logger.file_logger))

Logging.shouldlog(logger::Logger, level, _module, group, id) = Logging.shouldlog(logger.console_logger, level, _module, group, id) || Logging.shouldlog(logger.file_logger, level, _module, group, id)

Logging.handle_message(logger::Logger, level, message, _module, group, id, file, line; kwargs...) = begin
    message = "<$(time())>" * message
    Logging.handle_message(logger.console_logger, level, message, _module, group, id, file, line; kwargs...) # DEBUG
    Logging.handle_message(logger.file_logger, level, message, _module, group, id, file, line; kwargs...)
end

const file_stream(x) = open(joinpath(ROOT_DIR, "logs", "log-$(time())-$x"), "a")
const file_logger = SimpleLogger(file_stream("aos.txt"), Logging.Info)
const console_logger = ConsoleLogger(stdout, Logging.Info)
const logger = Logger(console_logger, file_logger)
global_logger(logger)


using PortAudio, Unitful, SampledSignals, ZMQ, Serialization, FileIO

const Time = Float64
struct AudioStream
    device::PortAudio.PortAudioDevice
    stream::PortAudioStream
    forward::Union{AudioStream, Nothing}
end
mutable struct AudioData
    speaker::String
    buffer::Union{SampleBuf{Float32,2},Nothing}
    what::String
    when::Time
end

function add_audio(id, speaker, f=_ -> true; forward=nothing)
    haskey(AUDIOS_STREAM, id) && return
    devices = PortAudio.devices()
    device = only(filter(d -> d.name == id && f(d), devices))
    stream = PortAudioStream(device, maximum, maximum, samplerate=FRAMES_PER_SECOND, frames_per_buffer=FRAMES_PER_BUFFER)
    AUDIOS_DATA[id] = AudioData(speaker, nothing, "", Time(0.0))
    AUDIOS_STREAM[id] = AudioStream(device, stream, forward)
end
add_usb_mic(;forward=nothing) = add_audio("USB Audio", "imi", d -> d.input_bounds.max_channels == 1 && d.output_bounds.max_channels == 0; forward=forward)
add_macbook_mic(;forward=nothing) = add_audio("MacBook Air Microphone", "imi"; forward=forward)
add_phone_line(;forward=nothing) = add_audio("BlackHole 2ch", "callee (potential buyer)"; forward=forward)
add_headphones() = add_audio("External Headphones", "callee (potential buyer)")

isinput(d) = 0 < d.input_bounds.max_channels

function record_audio()
    when = time()
    audios_stream = filter(a -> isinput(a[2].device), AUDIOS_STREAM)
    @sync for (id, audio_stream) in audios_stream
        @async begin
            audio_data = AUDIOS_DATA[id]
            audio_data.when = when
            chunks = []
            for _ in 1:div(FRAMES_PER_SECOND * DURATION.val, FRAMES_PER_BUFFER)
                # yield()
                try
                    chunk = read(audio_stream.stream, FRAMES_PER_BUFFER)
                    !isnothing(audio_stream.forward) && write(audio_stream.forward.stream, chunk)
                    push!(chunks, chunk)
                catch e
                    @show e
                    audio_data.buffer = nothing
                    break
                end
            end
            audio_data.buffer = vcat(chunks...)
            # save("/Users/1m1/$(time())-audio_data.ogg", audio_data.buffer)
        end
    end
end

function start_speaking()
    global SPEAKING_TASK = @async while SPEAKING[]
        yield()
        record_audio()
        buffer = IOBuffer()
        serialize(buffer, AUDIOS_DATA)
        message = Message(take!(buffer))
        send(ZMQ_SOCKET, message)
    end
end

const FRAMES_PER_SECOND = 16000
const FRAMES_PER_BUFFER = 2^9
const DURATION = 10s
const AUDIOS_DATA = Dict{String,AudioData}()
const AUDIOS_STREAM = Dict{String,AudioStream}()

const ZMQ_CONTEXT = ZMQ.context()
const ZMQ_SOCKET = Socket(ZMQ_CONTEXT, PUSH)
# connect(ZMQ_SOCKET, "tcp://192.168.1.88:8888")
connect(ZMQ_SOCKET, "tcp://100.92.55.73:8888")
const SPEAKING = Ref(true)

add_usb_mic()
# add_macbook_mic()
# add_macbook_mic(;forward=add_headphones())
# add_phone_line(;forward=add_headphones())
start_speaking()

# empty!(AUDIOS_DATA)
# empty!(AUDIOS_STREAM)
# close(STREAM)
# ZMQ.close(ZMQ_SOCKET)
# ZMQ.close(context)
# SPEAKING[]=false
# add_phone_line()
