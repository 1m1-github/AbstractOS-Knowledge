@api const OnlyCommunicateViaOutputDevices = """
communicate with the user using `OUTPUT_DEVICES`. if you have information that the user has specifically piped `stdout` to one of the `OUTPUT_DEVICES`, then you could also `print` or `show` etc. in addition to using other `OUTPUT_DEVICES`.
you do not need to check whether `OUTPUT_DEVICES` has a specific key, since you have been given which ones already exist.
"""