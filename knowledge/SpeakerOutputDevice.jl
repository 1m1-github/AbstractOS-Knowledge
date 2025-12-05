@api struct SpeechOutput <: OutputPeripheral end
OUTPUTS["speech"] = SpeechOutput()

"""
SpeechOutput <: OutputPeripheral allows text-to-speech output to talk
Use `put!(::SpeechOutput, text::String)` to speak the given text
Now you can talk to me
"""
@api function put!(::SpeechOutput, text::String)
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
