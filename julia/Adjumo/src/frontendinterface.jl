# Contains functions for use by the front-end.
# This file is part of the Adjumo module.

export scoresfordisplay

function scoresfordisplay(json::AbstractString)
    debate, panel = parsedebatepaneljson(json)
    return scoresfordisplay(debate, panel)
end