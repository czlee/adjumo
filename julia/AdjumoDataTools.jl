# This module provides tools for generating test data to try out Adjumo.
#
# It is not part of the core functionality of Adjumo. The importer for Tabbie2
# is part of the core functionality of Adjumo, so it is part of the Adjumo.jl
# module, not this one.
#
# Currently, this module has two tools:
#   - Generating random data ("random.jl")
#   - Importing data from a Tabbie1 PostgreSQL database ("importtabbie1.jl")
#
# Further commentary on each of these is in their respective files.
#
# Requirements:
#   Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
#   Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
# (Both of these are unregistered packages at time of writing.)

__precompile__()

module AdjumoDataTools
    using Adjumo
    export randomroundinfo, gettabbie1roundinfo
    export showteams, showadjudicators, showconstraints, showdebatedetail
    include("random.jl")
    include("importtabbie1.jl")
    include("display.jl")
end