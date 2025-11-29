import Pkg
Pkg.add("MiniFB")
using MiniFB

@api const MiniFBScreenOutputWIDTH = 2560
@api const MiniFBScreenOutputHEIGHT = 1600

mutable struct MiniFBOutput <: OutputDevice
    width
    height
    window
    buffer
end

"""
this knowledge allows you to show a rectangle of pixels on a screen
Use `put!(OUTPUT_DEVICES[:MiniFB]::MiniFBOutputDevice, buffer::Vector{UInt32})` to draw pixels to the MiniFB screen of size width=$MiniFBScreenOutputWIDTH,height=$MiniFBScreenOutputHEIGHT
"""
@api function put!(::MiniFBOutput, buffer::Vector{UInt32})
    OUTPUT_DEVICES[:MiniFB].buffer = buffer
end
describe(::MiniFBOutput) = MiniFB_OutputDevice

MiniFB_OutputDevice_window = mfb_open_ex("AbstractOS", MiniFBScreenOutputWIDTH, MiniFBScreenOutputHEIGHT, MiniFB.WF_RESIZABLE)
MiniFB_OutputDevice_buffer = rand(UInt32, MiniFBScreenOutputWIDTH*MiniFBScreenOutputHEIGHT)

OUTPUT_DEVICES[:MiniFB] = MiniFBOutput(MiniFBScreenOutputWIDTH, MiniFBScreenOutputHEIGHT, MiniFB_OutputDevice_window, MiniFB_OutputDevice_buffer)

@async while true
    state = mfb_update(OUTPUT_DEVICES[:MiniFB].window, OUTPUT_DEVICES[:MiniFB].buffer)
    if state != MiniFB.STATE_OK
        break
    end
    flush(stdout)
end
