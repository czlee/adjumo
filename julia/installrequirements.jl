# Installs all requirements and optional requirements for Adjumo except Gurobi.
# Usage:
#   julia installrequirements.jl
Pkg.add("JuMP")
Pkg.add("ArgParse")
Pkg.add("Formatting")
Pkg.add("Cbc")
Pkg.add("GLPKMathProgInterface")
Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
