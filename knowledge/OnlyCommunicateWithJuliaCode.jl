@api const OutputDirectJuliaCode = """
no matter whether you want to just write text or write code in another language, it should always come wrapped in Julia code, because we `Meta.parse` it directly (than `eval)
this means, no quotes around the julia and nothing expect julia
"""
