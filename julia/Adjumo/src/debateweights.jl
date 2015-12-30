OPEN_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 1, 1, 1, 1, 1, 1, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1],
    9=>Float64[1, 2, 1, 2, 1, 2],
)

ESL_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3.8, 3.6, 3.4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1],
    9=>Float64[1, 2, 1, 2, 1, 2],
)

EFL_DEBATE_WEIGHT_MAPS = Dict{Int,Vector{Float64}}(
    7=>Float64[1, 1, 3.8, 4, 4.2, 4.4, 4.6, 4.8, 5, 5, 5, 5, 4.8, 4.6, 4.4, 4.2, 4, 3.8, 3.6, 3.4, 3, 3, 3, 3, 3],
    8=>Float64[1, 1, 1, 1, 1, 1],
    9=>Float64[1, 2, 1, 2, 1, 2],
)

export computedebateweights!

function computedebateweights!(roundinfo::RoundInfo)
    for debate in roundinfo.debates
        weight = 0.0
        for team in debate.teams
            weight = OPEN_DEBATE_WEIGHT_MAPS[roundinfo.currentround][team.points+1]
            if team.language == EnglishSecond || team.language == EnglishForeign
                eslweight = ESL_DEBATE_WEIGHT_MAPS[roundinfo.currentround][team.points+1]
                if eslweight > weight
                    weight = eslweight
                end
            end
            if team.language == EnglishForeign
                eflweight = EFL_DEBATE_WEIGHT_MAPS[roundinfo.currentround][team.points+1]
                if eflweight > weight
                    weight = eflweight
                end
            end
        end
        debate.weight = weight
    end
end
