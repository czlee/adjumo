# Adjumo
*Allocating Debate Judges Using Mathematical Optimization*

## Getting started

### Julia & Julia Packages

You need to install Julia, and then install a bunch of Julia packages. Julia downloads are at http://julialang.org/downloads/.
Download and install the latest **stable** version, which is currently **0.4.1**.

You then need to install the required packages:
``` julia
julia> Pkg.add("JuMP")
julia> Pkg.add("Iterators")
julia> Pkg.add("ArgParse")
julia> Pkg.add("Formatting")
```

You also need to install a solver. There are three options: Gurobi, CBC and GLPK. You only need one of them.

**Option 1: Gurobi.** At the moment, I'm using Gurobi on an academic license. Gurobi is a commercial optimization solver.
To use it, you need to register for an account at http://www.gurobi.com/ and request an academic
license. Naturally, this requires you to be a student or staff member at a degree-granting institution.
If you can get hold of a Gurobi license:
``` julia
julia> Pkg.add("Gurobi")
```
*Note: This will fail if you don't have Gurobi installed.*

If you can't get a Gurobi license, then we can use one of the open-source solvers, CBC or GLPK.

**Option 2: CBC.** To install CBC:
``` julia
julia> Pkg.add("Cbc")
```

This will take a while and you'll see lots of gibberish printed on the screen. You need a C compiler, a C++ compiler and Make installed in order to build CBC. If you get error messages complaining about the lack of any of them, exit Julia and run these from the shell:
``` bash
$ sudo apt-get install gcc
$ sudo apt-get install g++
$ sudo apt-get install make
```

Then try again.

**Option 3: GLPK.** To install GLPK, first install the `libgmp-dev` package, from the shell (outside Julia):
``` bash
$ sudo apt-get install libgmp-dev
```

Then install in Julia:
``` julia
julia> Pkg.add("GLPKMathProgInterface")
```

GLPK (and Gurobi) supports MIP callbacks and CBC doesn't, and we might want MIP callbacks
in order to pull multiple solutions and have premature termination in there, so I'll probably want
to try harder with GLPK at some point.

### Front-End

- [Install Node.js](https://nodejs.org/en/)
- ```npm install```
- [Install Bower](http://bower.io)
- ```bower install```
- To start the server: ```DEBUG=adjumo:* npm start```
- Open ```http://0.0.0.0:3000/index.html```

## Running

### Julia part only

The file that tests the Julia part is called `trial.jl` and can be run directly from the shell:
``` bash
$ julia trial.jl
```

This generates random data for a pretend round and runs the algorithm on it. You can run it with a different number of debates, or pretend the current round is something else. For example, to run it with a round comprising 10 debates, pretending it is currently round 3:
``` bash
$ julia trial.jl -n 10 -r 3
```
