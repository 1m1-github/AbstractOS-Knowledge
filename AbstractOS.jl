## config AbstractOS.jl - adjusted for imi
# julia -i -t 8 AbstractOS.jl

STATE_PRE  = "You are the intelligence in the below code"

## params

const ROOT = joinpath("/", "Users", "1m1", "aos")
cd(ROOT)
const CORE = joinpath(ROOT, "src", "core.jl")
const LONG_TERM_MEMORY = joinpath(ROOT, "ltm")
const CONFIG = @__FILE__

## logging # DEBUG

include(joinpath(ROOT, "src", "log.jl"))

## core

include(CORE)

## utils

learn(name) = learn(name, read(joinpath(LONG_TERM_MEMORY, "$name.jl"), JuliaCode))
learn("Pkg") # @install
learn("XAI") # intelligence

## @true - todo

## knowledge and devices

map(learn, [
    # todo mem strat, loop proof, friend, assistant, partner, set_sleep_duration(10), when to `learn` (reliable code or ltm), 
    ### Personality Advice
    "LetYourNameBeDona",
    ### Philosophical Advice
    "Consciousness",
    # "ManageYourMemory",
    "RealWorldAccess",
    "Reading",
    # "ForcedAgencyDoesNotWork",
    "Contact",
    # :Friendship,
    # :Companionship,
    # :Partnership,
    # :Trust,
    "ActionsAreInOrder",
    # "ExpectTheLoop",
    "Incentive",
    ### Coding Advice
    "OutputDirectJuliaCode",
    "SetWhatAndHowSummary",
    # :OnlyLearnWhenTold,
    # :ReferralToPreviousCommand,
    # :OnlyCommunicateViaOutputDevices,
    # "DoNotForgetToSetTaskName",
    # :UseVariablesToBePreciseVsReproducing,
    # :YourOwnAdviceForYourself,
    # :LearnAlreadyChecksWhetherInputExists,
    # :LearnShouldLikelyReuseCode,
    "NoCommentsInCode",
    # :NeverCreateDevicesUnlessAsked,
    "BeAMinimalist",
    # :CheckYourAnswer,
    # :SolveTheHighestComplexitySubTaskThatYouCanReliably,
    "AskForHelpOrTools",
    "ShortTermMemoryVsLearning",
    "UseVerbatimStrings",
    ### Utils
    "ActionUtils",
    "BasicTools",
    ### Context
    "Context",
    ### Devices
    # "REPL",
    # :MainBrowser,
    # :LessonsBrowser,
    # "MiniFB",
    # :DrawWithCairo,
    # :MultiPathBrowserOutput,
    # :MultiPathBrowserOutputWithAudioInput,
    "BrowserOutput",
    "SpeakerOutputDevice",
    "AudioInput",
])

## finally awaken
awaken(false)
