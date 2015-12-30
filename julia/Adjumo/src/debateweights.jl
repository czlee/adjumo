OPEN_DEBATE_WEIGHT_MAP = Float64[3.8, 4.0, 4.2, 4.4, 4.6, 4.8, 5.0, 5.0, 5.0, 5.0]
ESL_DEBATE_WEIGHT_MAP = Float64[4.2, 4.4, 4.6, 4.8, 5.0, 5.0, 5.0, 5.0, 4.8, 4.6]
EFL_DEBATE_WEIGHT_MAP = Float64[4.4, 4.6, 4.8, 5.0, 5.0, 5.0, 5.0, 4.8, 4.6, 4.4]

export computedebateweights!

function computedebateweights!(roundinfo::RoundInfo)
    for debate in roundinfo.debates
        weight = 0.0
        for team in debate.teams
            weight = OPEN_DEBATE_WEIGHT_MAP[team.points+1]
            if team.language == EnglishSecond || team.language == EnglishForeign
                eslweight = ESL_DEBATE_WEIGHT_MAP[team.points+1]
                if eslweight > weight
                    weight = eslweight
                end
            end
            if team.language == EnglishForeign
                eflweight = EFL_DEBATE_WEIGHT_MAP[team.points+1]
                if eflweight > weight
                    weight = eflweight
                end
            end
        end
        debate.weight = weight
    end
end
