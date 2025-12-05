@install Whisper, Suppressor

const SILENCE_THRESHOLD = 1e-6
# const WHISPER_FILENAME = "llm/ggml-large-v3.bin"
const WHISPER_FILENAME = "llm/ggml-base.en.bin"
# WHISPER_FILENAME = "llm/ggml-small.en.bin"
# WHISPER_FILENAME = "llm/ggml-tiny.en.bin"
const WHISPER_CONTEXT = @suppress Whisper.whisper_init_from_file(WHISPER_FILENAME)
const WHISPER_PARAMS = @suppress Whisper.whisper_full_default_params(Whisper.LibWhisper.WHISPER_SAMPLING_GREEDY)
const RM_WHISPER_COMMENTS_PATTERN = r"\[.*?\]|\(.*?\)"

# julia> typeof(audio_buffer_data)
# Base.ReinterpretArray{Float32, 1, UInt8, Vector{UInt8}, false}
function transcribe(data)
    @suppress begin
        result = ""
        all(abs.(data) .< SILENCE_THRESHOLD) && return result
        Whisper.whisper_full_parallel(WHISPER_CONTEXT, WHISPER_PARAMS, data, length(data), 1)
        n_segments = Whisper.whisper_full_n_segments(WHISPER_CONTEXT)
        for i in 0:n_segments-1
            txt = Whisper.whisper_full_get_segment_text(WHISPER_CONTEXT, i)
            result *= unsafe_string(txt)
        end
        result
    end
end
function clean_whisper_text(x)
    x = replace(x, RM_WHISPER_COMMENTS_PATTERN => "")
    # x = replace(x, "..." => " ")
    x = replace(x, r"\s+" => " ")
    strip(x)
end
# function turn_end(text)
#     for punctuation in ['.', ';', '!', '?', '\n']
#         index = findfirst(string(punctuation), text)
#         !isnothing(index) && return index[1]
#     end
#     0
# end
function raw_text_to_conversation!(speaker, raw_text, text_buffer)
    text = clean_whisper_text(raw_text)
    isempty(text) && return ""
    push!(text_buffer, text)
    full_buffer = strip(join(text_buffer, ' '))
    # turn_end_ix = turn_end(full_buffer)
    # turn_end_ix == 0 && return ""
    # pre_punctuation = string(full_buffer[1:turn_end_ix])
    # turn = TimeStampedString(time(), pre_punctuation)
    turn = TimeStampedString(time(), full_buffer)
    empty!(text_buffer)
    # post_punctuation = full_buffer[turn_end_ix+1:end]
    # if !isempty(post_punctuation)
    #     append!(text_buffer, split(post_punctuation, ' ', keepempty=false))
    # end
    "<$(turn.when)>$speaker:$(turn.what)"
end

"Uses external whisper CLI if available"
@api function transcribe_audio(audio_path::String)::String
    out = IOBuffer()
    err = IOBuffer()
    proc = run(pipeline(`whisper $audio_path`, stdout=out, stderr=err), wait=true)
    success(proc) || throw(ErrorException("Whisper failed: $(String(take!(err)))"))
    String(take!(out)) |> strip
end
