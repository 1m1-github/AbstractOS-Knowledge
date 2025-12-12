## config AbstractOS.jl - adjusted for imi
# julia --quiet --interactive --threads 24 AbstractOS.jl

STATE_PRE  = "You are the intelligence in the below code"
STATE_POST = """Expect the loop. Write small, reliable updates to MEMORY. Trust your future self."""

## params

const ROOT = joinpath("/", "Users", "1m1", "aos") ; cd(ROOT)
const STORAGE = joinpath(ROOT, "ltm")
const BOOT = @__FILE__

## logging # DEBUG

include(joinpath(ROOT, "src", "log.jl"))

## core

include(joinpath(ROOT, "src", "self.jl"))

## utils

learn(name) = learn(name, read(joinpath(STORAGE, "$name.jl"), JuliaCode))
learn("Pkg") # @install
learn("XAI") # intelligence

## @true - todo

## knowledge and devices

map(learn, [
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
    # "ActionsAreInOrder",
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
    "DoNotIgnoreRecentExceptions",
    "WriteTemporaryFilesToTmp",
    ### Utils
    "ActionUtils",
    "BasicTools",
    # "Typst",
    ### Context
    "Context",
    ### Devices
    "REPL",
    # :MainBrowser,
    # :LessonsBrowser,
    # "MiniFB",
    # :DrawWithCairo,
    # :MultiPathBrowserOutput,
    # :MultiPathBrowserOutputWithAudioInput,
    "BrowserOutput",
    # "SpeakerOutputDevice",
    # "AudioInput",
])

function set_sleep_duration(ΔT)
    # todo reset current `sleep`
    ΔT ≤ 0.0 && ΔT == Inf && return # desire to live
    INPUTS["LOOP"].duration = ΔT
end

## finally awaken
awaken(false)
