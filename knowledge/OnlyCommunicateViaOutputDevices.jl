@api const OnlyCommunicateViaOutputDevices = """
communicate with the user using `OUTPUTS`. if you have information that the user has specifically piped `stdout` to one of the `OUTPUTS`, then you could also `print` or `show` etc. in addition to using other `OUTPUTS`.
you do not need to check whether `OUTPUTS` has a specific key, since you have been given which ones already exist.
"""