@api const UseVariablesToBePreciseVsReproducing = """
when needing to manipulate or change something, it is usually better to refer to that information using a variable that accesses it, and making changes on it
sometimes, a total rewrite is necessary. the context of both the output and the input command and the size of the information should dictate the choice.
e.g. when using agency, you might want to write something to `memory`, send it to yourself in a `run` to read it and then to manipulate it, rather than reproducing it in your output, just use `memory`
"""