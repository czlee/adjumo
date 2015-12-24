# Performance profiling for parallel computation of region scores

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: getdebateweights, matrixfromvector, regionalrepresentationmatrix, languagerepresentationmatrix, genderrepresentationmatrix, teamadjhistorymatrix, teamadjconflictsmatrix, qualityvector, adjadjhistoryvector, adjadjconflictsvector
using AdjumoDataTools

function scorematrix1(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    Σ  = componentweights.quality      * matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Σ += componentweights.regional     * regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.language     * languagerepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.gender       * genderrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.teamhistory  * teamadjhistorymatrix(feasiblepanels, roundinfo)
    Σ += componentweights.adjhistory   * matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Σ += componentweights.teamconflict * teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.adjconflict  * matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    Σ = weightedαfairness(debateweights, Σ, componentweights.α)
    return Σ
end

function scorematrix2(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    Π  = @spawn @time matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Πα = @spawn @time regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Γα = @spawn @time languagerepresentationmatrix(feasiblepanels, roundinfo)
    Φα = @spawn @time genderrepresentationmatrix(feasiblepanels, roundinfo)
    Ht = @spawn @time teamadjhistorymatrix(feasiblepanels, roundinfo)
    Ha = @spawn @time matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Ct = @spawn @time teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Ca = @spawn @time matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    Σ  = componentweights.quality      * fetch(Π)
    Σ += componentweights.regional     * fetch(Πα)
    Σ += componentweights.language     * fetch(Γα)
    Σ += componentweights.gender       * fetch(Φα)
    Σ += componentweights.teamhistory  * fetch(Ht)
    Σ += componentweights.adjhistory   * fetch(Ha)
    Σ += componentweights.teamconflict * fetch(Ct)
    Σ += componentweights.adjconflict  * fetch(Ca)
    Σ = weightedαfairness(debateweights, Σ, componentweights.α)
    return Σ
end

function scorematrix3(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    Π  = @spawnat 2 @time matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Πα = @spawnat 3 @time regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Γα = @spawnat 4 @time languagerepresentationmatrix(feasiblepanels, roundinfo)
    Φα = @spawnat 5 @time genderrepresentationmatrix(feasiblepanels, roundinfo)
    Ht = @spawnat 6 @time teamadjhistorymatrix(feasiblepanels, roundinfo)
    Ha = @spawnat 7 @time matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Ct = @spawnat 8 @time teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Ca = @spawnat 9 @time matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    Σ  = componentweights.quality      * fetch(Π)
    Σ += componentweights.regional     * fetch(Πα)
    Σ += componentweights.language     * fetch(Γα)
    Σ += componentweights.gender       * fetch(Φα)
    Σ += componentweights.teamconflict * fetch(Ct)
    Σ += componentweights.adjconflict  * fetch(Ca)
    Σ += componentweights.teamhistory  * fetch(Ht)
    Σ += componentweights.adjhistory   * fetch(Ha)
    Σ = weightedαfairness(debateweights, Σ, componentweights.α)
    return Σ
end

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
    "--tabbie1"
        help = "Import a Tabbie1 database: <username> <password> <database>"
        metavar = "ARG"
        nargs = 3
    "--tabbie2"
        help = "Import a Tabbie2 export file"
        metavar = "JSONFILE"
        default = ""
    "-l", "--limitpanels"
        help = "Limit how many panels it samples"
        arg_type = Int
        default = typemax(Int)
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
if length(args["tabbie2"]) > 0
    tabbie2file = open(args["tabbie2"])
    roundinfo = importtabbiejson(tabbie2file)
elseif length(args["tabbie1"]) > 0
    using DBI
    using PostgreSQL
    username, password, database = args["tabbie1"]
    dbconnection = connect(Postgres, "localhost", username, password, database, 5432)
    roundinfo = gettabbie1roundinfo(dbconnection, currentround)
else
    roundinfo = randomroundinfo(ndebates, currentround)
end
feasiblepanels = generatefeasiblepanels(roundinfo; limitpanels=args["limitpanels"])

# once first to compile
smallroundinfo = randomroundinfo(5, 2)
smallfeasiblepanels = generatefeasiblepanels(smallroundinfo)
scorematrix1(smallroundinfo, smallfeasiblepanels)
scorematrix2(smallroundinfo, smallfeasiblepanels)

println("parallel spawn:")
@time B = scorematrix2(roundinfo, feasiblepanels)
println("parallel spawnat:")
@time C = scorematrix3(roundinfo, feasiblepanels)
println("serial:")
@time A = scorematrix1(roundinfo, feasiblepanels)
@show size(A)
@show size(B)
@show size(C)
@show sumabs(A-B)
@show maxabs(A-B)
@show sumabs(B-C)
@show maxabs(B-C)
@show sumabs(A-C)
@show maxabs(A-C)
