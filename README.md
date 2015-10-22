# Adjumo
*Allocating Debate Judges Using Mathematical Optimization*

## Getting started

You need to install Julia, and then install a bunch of Julia packages. Julia downloads are at http://julialang.org/downloads/. 
Download and install the latest **stable** version, which is currently **0.4.0**.

You then need to install the required packages:
``` julia
julia> Pkg.add("JuMP")
julia> Pkg.add("Iterators")
```

At the moment, I'm using Gurobi on an academic license. Gurobi is a commercial optimization solver. 
To use it, you need to register for an account at http://www.gurobi.com/ and request an academic
license. Naturally, this requires you to be a student or staff member at a degree-granting institution.
If you can get hold of a Gurobi license:
``` julia
julia> Pkg.add("Gurobi")
```
*Note: This will fail if you don't have Gurobi installed.*

If you can't get a Gurobi license, then we can use one of the open-source solvers. I've tried CBC:
``` julia
julia> Pkg.add("Cbc")
```

You only need one of Gurobi and CBC.

I've also got a line in for `GLPKMathProgInterface`, but it doesn't work very well right now, not
sure why. GLPK (and Gurobi) supports MIP callbacks and CBC doesn't, and we might want MIP callbacks
in order to pull multiple solutions and have premature termination in there, so I'll probably want
to try harder with GLPK at some point.
