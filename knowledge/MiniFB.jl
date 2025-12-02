@install MiniFB

@api const MiniFBScreenWIDTH = 2560
@api const MiniFBScreenHEIGHT = 1600

mutable struct MiniFBScreen <: OutputPeripheral
    width
    height
    window
    buffer
end

"""
this knowledge allows you to show a rectangle of pixels on a screen
Use `put!(OUTPUTS["MiniFB"]::MiniFB, buffer::Vector{UInt32})` to draw pixels to the MiniFBScreen of size width=$MiniFBScreenWIDTH,height=$MiniFBScreenHEIGHT
"""
@api put!(::MiniFBScreen, buffer::Vector{UInt32}) = OUTPUTS["MiniFB"].buffer = buffer

MiniFB_OutputDevice_window = mfb_open_ex("AbstractOS", MiniFBScreenWIDTH, MiniFBScreenHEIGHT, MiniFB.WF_RESIZABLE)
MiniFB_OutputDevice_buffer = rand(UInt32, MiniFBScreenWIDTH*MiniFBScreenHEIGHT)

OUTPUTS["MiniFB"] = MiniFBScreen(MiniFBScreenWIDTH, MiniFBScreenHEIGHT, MiniFB_OutputDevice_window, MiniFB_OutputDevice_buffer)

@async while true
    state = mfb_update(OUTPUTS["MiniFB"].window, OUTPUTS["MiniFB"].buffer)
    if state != MiniFB.STATE_OK
        break
    end
    flush(stdout)
end
