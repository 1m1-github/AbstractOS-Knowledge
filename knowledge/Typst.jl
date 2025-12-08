@install Images

"""
Will compile and blend the typst code onto the MiniFB screen with it's top left starting at (x,y)
The entire screen goes from (0.0,0.0) top left to (1.0,1.0) bottom right
Use this to write or chart onto the screen
The page is already set to `auto` size: #set page(width:auto,height:auto,margin:0pt,fill:none) [this is added on top of your `typst_code`]
"""
@api function draw_typst_code_on_minifb(typst_code::String, top_left_x::Float64, top_left_y::Float64)
    typ_path = "tmp/text.typ"
    png_path = "tmp/text.png"
    typst_code = """
    #set page(width:auto,height:auto,margin:0pt,fill:none)
    $typst_code
    """
    write_file(typ_path, typst_code) # todo in memory
    run_shell(`typst compile $typ_path $png_path`)
    img = load(png_path)
    put!(OUTPUTS["MiniFB"], img, top_left_x, top_left_y)
end

to_minifb(c::RGBA{N0f8}) = reinterpret(UInt32, ARGB32(c))
