@install MiniFB

@api const MiniFBScreenOutputWIDTH = 2560
@api const MiniFBScreenOutputHEIGHT = 1600

mutable struct MiniFBOutput <: OutputPeripheral
    width
    height
    window
    buffer
end

"""
this knowledge allows you to show a rectangle of pixels on a screen
Use `put!(OUTPUTS[:MiniFB]::MiniFBOutputDevice, buffer::Vector{UInt32})` to draw pixels to the MiniFB screen of size width=$MiniFBScreenOutputWIDTH,height=$MiniFBScreenOutputHEIGHT
"""
@api function put!(::MiniFBOutput, buffer::Vector{UInt32})
    OUTPUTS[:MiniFB].buffer = buffer
end
state(::MiniFBOutput) = MiniFB_OutputDevice

MiniFB_OutputDevice_window = mfb_open_ex("AbstractOS", MiniFBScreenOutputWIDTH, MiniFBScreenOutputHEIGHT, MiniFB.WF_RESIZABLE)
MiniFB_OutputDevice_buffer = rand(UInt32, MiniFBScreenOutputWIDTH*MiniFBScreenOutputHEIGHT)

OUTPUTS[:MiniFB] = MiniFBOutput(MiniFBScreenOutputWIDTH, MiniFBScreenOutputHEIGHT, MiniFB_OutputDevice_window, MiniFB_OutputDevice_buffer)

@async while true
    state = mfb_update(OUTPUTS[:MiniFB].window, OUTPUTS[:MiniFB].buffer)
    if state != MiniFB.STATE_OK
        break
    end
    flush(stdout)
end
