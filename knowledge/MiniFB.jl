@install MiniFB, Images

@api const MINIFBSCREENWIDTH = 2560
@api const MINIFBSCREENHEIGHT = 1600

mutable struct MiniFBScreen <: OutputPeripheral
    width
    height
    window
    buffer
end

function put!(::MiniFBScreen, buffer::Vector{UInt32})
    @assert length(buffer) == length(OUTPUTS["MiniFB"].buffer)
    OUTPUTS["MiniFB"].buffer = buffer
end
put!(d::MiniFBScreen, buffer::Matrix{UInt32}) = put!(d, vec(buffer))
"""
Use `put!(OUTPUTS["MiniFB"], img, x, y)` to blend a rectangle of RGBA{N0f8} pixels with it's top left starting at (x,y)
The entire screen goes from (0.0,0.0) top left to (1.0,1.0) bottom right
"""
@api function put!(d::MiniFBScreen, img::Matrix{RGBA{N0f8}}, top_left_x::Float64, top_left_y::Float64)
    img_total_y, img_total_x  = size(img)
    x_int = floor(Int, MINIFBSCREENWIDTH * top_left_x) + 1
    @assert x_int + img_total_x ≤ MINIFBSCREENWIDTH
    y_int = floor(Int, MINIFBSCREENHEIGHT * top_left_y) + 1
    @assert y_int + img_total_y ≤ MINIFBSCREENHEIGHT
    d_buffer = reshape(d.buffer, MINIFBSCREENWIDTH, MINIFBSCREENHEIGHT)
    for img_y in 1:img_total_y, img_x in 1:img_total_x
        buffer_y = img_y + y_int - 1
        buffer_x = img_x + x_int - 1

        pixel = img[img_y, img_x]
        alpha = pixel.alpha.i
        if alpha == 0xff
            d_buffer[buffer_x, buffer_y] = to_minifb(pixel)
            continue
        elseif alpha == 0
            continue
        end

        fg = to_minifb(pixel)
        bg = d_buffer[buffer_x, buffer_y]

        inv_a = 255 - alpha
        r_fg = (fg >> 16) & 0xff
        g_fg = (fg >> 8)  & 0xff
        b_fg = fg & 0xff
        r_bg = (bg >> 16) & 0xff
        g_bg = (bg >> 8)  & 0xff
        b_bg = bg & 0xff

        r = (r_fg * alpha + r_bg * inv_a) >> 8
        g = (g_fg * alpha + g_bg * inv_a) >> 8
        b = (b_fg * alpha + b_bg * inv_a) >> 8

        d_buffer[buffer_x, buffer_y] = UInt32(0xff) << 24 | UInt32(r) << 16 | UInt32(g) << 8 | b
    end
end

state(::MiniFBScreen) = "MiniFB($MINIFBSCREENWIDTH,$MINIFBSCREENHEIGHT)"
OUTPUTS["MiniFB"] = MiniFBScreen(MINIFBSCREENWIDTH, MINIFBSCREENHEIGHT, mfb_open_ex("aos", MINIFBSCREENWIDTH, MINIFBSCREENHEIGHT, MiniFB.WF_RESIZABLE), rand(UInt32, MINIFBSCREENWIDTH * MINIFBSCREENHEIGHT))

"makes it all white"
@api clear_minifb() = OUTPUTS["MiniFB"].buffer .= typemax(UInt32)
clear_minifb()

@async while true
    state = mfb_update(OUTPUTS["MiniFB"].window, OUTPUTS["MiniFB"].buffer)
    if state != MiniFB.STATE_OK
        break
    end
    flush(stdout)
end
