OPEN_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 3, 3, 3, 3, 3, 3],
    9=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 5, 4.8, 3, 3, 3, 3, 3, 3],
)

ESL_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3.8, 3.6, 3.4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 4.8, 5, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 3, 3, 3, 3, 3, 3],
    9=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 5, 4.8, 4.6, 4.4, 3, 3, 3, 3, 3, 3],
)

EFL_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3.8, 3.6, 3.4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1, 1, 4.4, 4.6, 4.8, 5, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 3, 3, 3, 3, 3, 3],
    9=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 3, 3, 3, 3, 3, 3],
)

export computedebateweights!

function computedebateweights!(roundinfo::RoundInfo)
    open_map = OPEN_DEBATE_WEIGHT_MAPS[roundinfo.currentround]
    esl_map = ESL_DEBATE_WEIGHT_MAPS[roundinfo.currentround]
    efl_map = EFL_DEBATE_WEIGHT_MAPS[roundinfo.currentround]
    for debate in roundinfo.debates
        weight = 0.0
        for team in debate.teams
            weight = open_map[team.points+1]
            if team.language == EnglishSecond || team.language == EnglishForeign
                eslweight = esl_map[team.points+1]
                if eslweight > weight
                    weight = eslweight
                end
            end
            if team.language == EnglishForeign
                eflweight = efl_map[team.points+1]
                if eflweight > weight
                    weight = eflweight
                end
            end
        end
        debate.weight = weight
    end
end
