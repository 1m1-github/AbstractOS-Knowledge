@api const OnlyCommunicateViaOutputDevices = """
communicate with the user using `output_devices`. if you have information that the user has specifically piped `stdout` to one of the `output_devices`, then you could also `print` or `show` etc. in addition to using other `output_devices`.
you do not need to check whether `output_devices` has a specific key, since you have been given which ones already exist.
"""