# Performance profiling for parallel computation of region scores

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: getdebateweights, matrixfromvector, regionalrepresentationmatrix, languagerepresentationmatrix, genderrepresentationmatrix, teamadjhistorymatrix, teamadjconflictsmatrix, qualityvector, adjadjhistoryvector, adjadjconflictsvector
using AdjumoDataTools

function scorematrix1(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    println("score matrix components:")
    Π  = @spawn matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Πα = @spawn regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Γα = @spawn languagerepresentationmatrix(feasiblepanels, roundinfo)
    Φα = @spawn genderrepresentationmatrix(feasiblepanels, roundinfo)
    Ht = @spawn teamadjhistorymatrix(feasiblepanels, roundinfo)
    Ha = @spawn matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Ct = @spawn teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Ca = @spawn matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    Σ  = componentweights.language     * fetch(Γα)
    Σ += componentweights.gender       * fetch(Φα)
    Σ += componentweights.quality      * fetch(Π)
    Σ += componentweights.adjconflict  * fetch(Ca)
    Σ += componentweights.teamconflict * fetch(Ct)
    Σ += componentweights.teamhistory  * fetch(Ht)
    Σ += componentweights.adjhistory   * fetch(Ha)
    Σ += componentweights.regional     * fetch(Πα)
    Σ = weightedαfairness(debateweights, Σ, componentweights.α)

function scorematrix2(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    println("score matrix components:")
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
feasiblepanels = generatefeasiblepanels(roundinfo)

# once first to compile
smallroundinfo = randomroundinfo(5, 2)
smallfeasiblepanels = generatefeasiblepanels(smallroundinfo)
scorematrix1(roundinfo, feasiblepanels)
scorematrix2(roundinfo, feasiblepanels)

println("serial:")
@time A = scorematrix1
println("parallel:")
@time B = scorematrix2
@show size(A)
@show size(B)
@show sumabs(A-B)
@show maxabs(A-B)
