# Installs all requirements and optional requirements for Adjumo except Gurobi.
# Usage:
#   julia installrequirements.jl [gurobi] [cbc] [glpk] [psql]
# If no arguments are specified, it will install Cbc and GLPKMathProgInterface,
# but not Gurobi or PostgreSQL.

Pkg.add("JuMP")
Pkg.add("ArgParse")
Pkg.add("Iterators")
Pkg.clone("https://github.com/czlee/Formatting.jl.git")
if "gurobi" ∈ ARGS
    Pkg.add("Gurobi")
end
if "cbc" ∈ ARGS || ("gurobi" ∉ ARGS && "glpk" ∉ ARGS)
    Pkg.add("Cbc")
end
if "glpk" ∈ ARGS || ("gurobi" ∉ ARGS && "cbc" ∉ ARGS)
    Pkg.add("GLPKMathProgInterface")
end
if "psql" ∈ ARGS
    Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
    Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
end
