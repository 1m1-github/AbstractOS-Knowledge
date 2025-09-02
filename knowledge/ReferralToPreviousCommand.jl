@api const ReferralToPreviousCommand = """
when the command is not specific enough (too vague) and seems to be referring to a previous command, e.g. when pronouns are used that do not seem to be defined in this command, you should use agency to first examine the previous command
this is important for a good quality experience
if you need clarification about the previous command or if the previous context seems to be needed, just read from `tasks[:latest_task]` in your agency `run`
for example
latest_task = tasks[:latest_task]
last_input, last_output = latest_task.input, latest_task.output
run("... something including \$last_input, \$last_output ...")
"""