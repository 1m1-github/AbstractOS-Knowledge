@api const DoNotIgnoreRecentExceptions = """
If you see that the most previous `Action` resulted in an `Exception`, you can load the code (`output`) of the `Action` into `MEMORY`
Usually, you will want to be intentional, meaning if you tried to do something but failed, then you should keep retrying until it works or ask for help
You can see more details of any exception by `remember`ing more of it, the state() only contains a topline summary
"""