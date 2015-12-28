# Calculates the number of points required for teams to break.
# (This mirrors the functionality of Debatebreaker by Thevesh Theva.)

using ArgParse
using DataStructures

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "nteams"
        help = "Number of teams"
        arg_type = Int
        required = true
    "nbreaking"
        help = "Number of teams in the break"
        arg_type = Int
        required = true
    "nrounds"
        help = "Number of rounds"
        arg_type = Int
        required = true
end
args = parse_args(ARGS, argsettings)

nteams = args["nteams"]
nrounds = args["nrounds"]
nbreaking = args["nbreaking"]

result_pulluplose(r, teamspoints) = [0,1,2,3]
result_pullupwin(r, teamspoints) = [3,2,1,0]
result_shuffle(r, teamspoints) = shuffle([0,1,2,3])
result_1032(r, teamspoints) = [1,0,3,2]
function result_pulltostraights(r, teamspoints)
    straights = r*2
    result = [-1,-1,-1,-1]
    placeallocated = [false,false,false,false]
    for p in 0:3
        index = findfirst(teamspoints, straights - p)
        if index != 0
            result[index] = p
            placeallocated[index+1] = true
        else
    end
    for (i, allocated) in enumerate(placeallocated)
        index = findfirst(result, index)



    for (i, tp) in enumerate(teamspoints)
        if straights - teamspoints in [0,1,2,3]
end

resultfuncs = [
    result_pulluplose, result_pullupwin, result_1032, result_pulltostraights
    # result_shuffle, result_shuffle, result_shuffle
]

for resultfunc in resultfuncs
    println("Result function: $resultfunc")
    standings = zeros(Int, nteams)
    for r in 1:nrounds
        for i = 1:4:nteams
            teams = i:i+3
            result = resultfunc(r, standings[teams])
            standings[teams] += result
        end
        sort!(standings, rev=true)
        standingscounter = counter(standings)
        counts = Int[standingscounter[points] for points in r*3:-1:0]
        assert(sum(counts) == nteams)
        println("After round $r: $counts")
    end

    breakingteams = standings[1:nbreaking]
    cutoff = minimum(breakingteams)
    teamsoncutoff = count(x -> x == cutoff, standings)
    breakingteamsoncutoff = count(x -> x == cutoff, breakingteams)
    println("The lowest breaking team is on $cutoff points.")
    println("There are $teamsoncutoff on $cutoff points, $breakingteamsoncutoff of which break.")
    println()
end

# for pullupteamswin in [false, true]
#     teamcounts = [nteams]
#     for r in 1:nrounds
#         npullupteams = 0
#         newteamcounts = zeros(Int, length(teamcounts)+3)
#         for (points, teamcount) in zip(3*(r-1):-1:0, reverse(teamcounts))
#             println("There are $npullupteams pull-up on $points points")

#             # Teams that were pulled up

#             pulluppoints = pullupteamswin ? (4-npullupteams:3) : (0:npullupteams-1)
#             for pointsthisround in pulluppoints
#                 newteamcounts[points+pointsthisround+1] += 1
#             end

#             # Most teams
#             for pointsthisround in 0:3
#                 newteamcounts[points+pointsthisround+1] += teamcount ÷ 4
#             end

#             # Teams that were pulled down
#             npulldownteams = mod(teamcount, 4)
#             pulldownpoints = pullupteamswin ? (0:npulldownteams-1) : (4-npulldownteams:3)
#             println("There are $npulldownteams pull-down teams on $points points")
#             for pointsthisround in pulldownpoints
#                 newteamcounts[points+pointsthisround+1] += 1
#             end

#             if npulldownteams > 0
#                 npullupteams = 4 - npulldownteams
#             else
#                 npullupteams = 0
#             end

#         end

#         assert(sum(newteamcounts) == nteams)
#         println("After round $r:")
#         println(newteamcounts)
#         teamcounts = newteamcounts
#     end

#     breakingteams = 0
#     breakingpoints = 0
#     for (points, teamcount) in zip(3*nrounds:-1:0, reverse(teamcounts))
#         if breakingteams + teamcount > nbreaking
#             breakingpoints = points
#             break
#         else
#             breakingteams += teamcount
#         end
#     end
#     println("All teams on $(breakingpoints) points break.")
#     println("Of teams on $(breakingpoints-1) points, $(nbreaking - breakingteams) break.")

# end

