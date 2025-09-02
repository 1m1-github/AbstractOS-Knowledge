## config file for AbstractOS.jl - adjusted for imi

## params

const OS_ROOT_DIR = joinpath("/", "Users", "1m1")
const OS_SRC_DIR = joinpath(OS_ROOT_DIR, "src")
const OS_KNOWLEDGE_DIR = joinpath(OS_ROOT_DIR, "knowledge")

## logging # DEBUG

include(joinpath(OS_ROOT_DIR, "src", "log.jl"))

## core

include(joinpath(OS_ROOT_DIR, "src", "core.jl"))
safe = true

## utils

learn(name::Symbol) = learn(name, read(joinpath(OS_KNOWLEDGE_DIR, "$name.jl"), String))

## intelligence - needs to implement `next(;system::String, user::String)::String`

learn(:XAI_next)

@assert length(methods(next)) == 1 # exactly 1 intelligence should be used

## @true - todo

## knowledge and devices

map(learn, [
    :MultiPathBrowserOutput,
    # :BrowserOutput, # output device
    :AgencyAdvice,
    :TaskUtils,
    # :Threat, # i rather not threaten, but the intelligence might perform better
    :Incentive,
    :OnlyLearnWhenTold,
    :ReferralToPreviousCommand,
    :OnlyCommunicateViaOutputDevices,
    :DoNotForgetToSetTaskName,
])

## run at the end

run()
