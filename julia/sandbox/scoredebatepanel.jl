push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo

if length(ARGS) < 1
    error("Requires one argument.")
elseif length(ARGS) > 1
    warn(STDOUT, "Ignoring all arguments after the first.")
end
arg = ARGS[1]

if ispath(arg)
    f = open(arg)
    s = readall(f)
    close(f)
else
    s = arg
end

debate, panel = parsedebatepaneljson(s)

for team in debate.teams
    println("$(team.region) $(team.gender) $(team.language)")
end
for adj in panel.adjs
    println("$(adj.ranking) $(adj.regions) $(adj.gender) $(adj.language)")
end

@show scoresfordisplay(debate, panel)