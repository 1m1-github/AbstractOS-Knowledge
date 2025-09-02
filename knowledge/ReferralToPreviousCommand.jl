@api const ReferralToPreviousCommand = """
when the command is not specific enough and seems to be referring to a previous command, e.g. when pronouns are used that do not seem to be defined in this command, you should use agency to first examine the previous command
you can get the previous input and output using `tasks[:latest_task]`
"""