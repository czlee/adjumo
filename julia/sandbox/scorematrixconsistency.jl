push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using AdjumoDataTools

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "-n", "--ndebates"
        help = "Number of debates in round"
        arg_type = Int
        default = 5
    "-r", "--currentround"
        help = "Current round number"
        arg_type = Int
        default = 5
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
roundinfo = randomroundinfo(ndebates, currentround)
panels = generatefeasiblepanels(roundinfo; fpgmethod=:random, nfeasiblepanels=5)

function scorematrixlong(roundinfo, panels)
    Σ = Matrix{Float64}(length(roundinfo.debates), length(panels))
    for (p, panel) in enumerate(panels), (d, debate) in enumerate(roundinfo.debates)
        Σ[d,p] = score(roundinfo, debate, panel)
    end
    return Σ
end

function scorematrixtrainees(roundinfo, panels)
    inst = Institution(1, "a", "b")
    Σ = Matrix{Float64}(length(roundinfo.debates), length(panels))
    for (p, panel) in enumerate(panels), (d, debate) in enumerate(roundinfo.debates)
        push!(panel.adjs, Adjudicator(1, "hello", inst))
        Σ[d,p] = score(roundinfo, debate, panel)
    end
    return Σ
end

function scorematrixcompare(roundinfo, panels)
    inst = Institution(1, "a", "b")
    Σ = Matrix{Float64}(length(roundinfo.debates), length(panels))
    for (p, panel) in enumerate(panels), (d, debate) in enumerate(roundinfo.debates)
        println("original:")
        @show score(roundinfo, debate, panel)
        @show panelquality(panel)
        @show panelregionalrepresentationscore(debate, panel)
        @show panellanguagerepresentationscore(debate, panel)
        @show panelgenderrepresentationscore(debate, panel)
        @show teamadjhistoryscore(roundinfo, debate, panel)
        @show adjadjhistoryscore(roundinfo, panel)
        @show teamadjconflictsscore(roundinfo, debate, panel)
        @show adjadjconflictsscore(roundinfo, panel)
        push!(panel.adjs, Adjudicator(1, "hello", inst))
        revised = score(roundinfo, debate, panel)
        println("revised:")
        @show score(roundinfo, debate, panel)
        @show panelquality(panel)
        @show panelregionalrepresentationscore(debate, panel)
        @show panellanguagerepresentationscore(debate, panel)
        @show panelgenderrepresentationscore(debate, panel)
        @show teamadjhistoryscore(roundinfo, debate, panel)
        @show adjadjhistoryscore(roundinfo, panel)
        @show teamadjconflictsscore(roundinfo, debate, panel)
        @show adjadjconflictsscore(roundinfo, panel)
        println()
    end
    return Σ
end

A = scorematrix(roundinfo, panels)
B = scorematrixlong(roundinfo, panels)
C = scorematrixtrainees(roundinfo, panels)

@show sumabs(A)
@show sumabs(B)
@show sumabs(C)
@show sumabs(A-B)
@show sumabs(A-C)
@show sumabs(B-C)

scorematrixcompare(roundinfo, panels)