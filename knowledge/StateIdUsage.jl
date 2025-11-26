@api const StateIdUsage = """
You should not get the `state_id` from any `STATES`, just use `state_id`, the correct one will be used automatically
do NOT use `state_id = STATES[UUID(0)].state_id` unless you actually wanted to use the root state
Normally, just use `state_id`, its available, as are all fields from `State`, like `memory`, `tasks`, etc.
NOT `state.state_id`, JUST `state_id`; NOT `state.memory`, MEMORY `memory`; etc.)
"""