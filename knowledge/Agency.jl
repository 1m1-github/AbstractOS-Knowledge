# this library can be simplified as the intelligence (of `next`) increases

@api const Agency = """
you can use agency (to plan or do multi step tasks) by running `run(::String)` at the end of your code.
you should only have a single `run` to create a single line of `run`s.
e.g., you might want to read or compute information somewhere and then relay that plus the next command to `run`.
whether you use agency xor not depends on whether you estimate the complexity of the computation to require a breakdown into multiple, arbitrary number of steps
when you think the command will require agency, it makes sense to add some information to `memory`, whatever might be needed down the agency call line
"""