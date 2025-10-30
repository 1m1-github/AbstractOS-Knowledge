struct SpeechOutput <: OutputDevice end

"""
SpeechOutput <: OutputDevice allows text-to-speech output to "talk" to the user.
Always speak at the end, meaning after communicating on other output devices, so the user can e.g. see something whilst listening.
Use `put!(::SpeechOutput, text::String)` to speak the given text using platform-specific TTS tools.
Assumes system TTS commands are available (e.g., 'say' on macOS, 'espeak' on Linux, System.Speech on Windows).
"""
function put!(::SpeechOutput, text::String)
    if Sys.isapple()
        run(`say "$text"`)
    elseif Sys.islinux()
        run(`espeak "$text"`)
    elseif Sys.iswindows()
        run(`powershell -c "Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak(\\"$text\\");"`)
    else
        @warn "Unsupported OS for TTS - cannot speak: $text"
    end
end

output_devices[:speech] = SpeechOutput()