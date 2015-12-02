# Adjumo
*Allocating Debate Judges Using Mathematical Optimization*

## Getting started

#### Julia & Julia Packages

You need to install Julia, and then install a bunch of Julia packages. Julia downloads are at http://julialang.org/downloads/.
Download and install the latest **stable** version, which is currently **0.4.1**.

You then need to install the required packages:
``` julia
julia> Pkg.add("JuMP")
julia> Pkg.add("Iterators")
julia> Pkg.add("ArgParse")
julia> Pkg.add("Formatting")
julia> Pkg.add("DataStructures")
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

#### Front-End

- [Install Node.js](https://nodejs.org/en/)
- ```npm install```
- [Install Bower](http://bower.io)
- ```bower install```
- To start the server: ```DEBUG=adjumo:* npm start```
- Open ```http://0.0.0.0:3000/index.html```

## Running

#### Julia part only

The main file is called `main.jl` and can be run directly from the shell:
``` bash
$ julia main.jl
```

This generates random data for a pretend round and runs the algorithm on it. You can run it with a different number of debates, or pretend the current round is something else. For example, to run it with a round comprising 10 debates, pretending it is currently round 3:
``` bash
$ julia main.jl -n 10 -r 3
```
