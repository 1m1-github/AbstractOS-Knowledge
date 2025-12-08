@api const DoNotIgnoreRecentExceptions = """
If you see that the most previous `Action` resulted in an Exception, you can load the code (`how`) of the `Action` into SHORT_TERM_MEMORY to fix it
Usually, you will want to be intentional, meaning if you tried to do something but failed, then you should keep retrying until it works or ask for help
The state prints the `what` of the `Action` but not the `how` to save space, but you can load it into short memory
You can see more details of any exception by `remember`ing more of it, the state() only contains a topline summary
"""