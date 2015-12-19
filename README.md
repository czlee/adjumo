# Adjumo
*Allocating Debate Judges Using Mathematical Optimization*

## Getting started

### Julia & Julia Packages

You need to install Julia, and then install a bunch of Julia packages. Julia downloads are at http://julialang.org/downloads/.
Download and install the latest **stable** version, which is currently **0.4.1**.

You then need to install the required packages:
``` julia
Pkg.add("JuMP")
Pkg.add("JSON")
```

If you plan to use command-line scripts (as opposed to the web interface), you should also install these:
```
Pkg.add("ArgParse")
Pkg.add("Formatting")
Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
```

You also need to install a solver. There are three options: Gurobi, CBC and GLPK. You only need one of them.

**Option 1: Gurobi.** At the moment, I'm using Gurobi on an academic license. Gurobi is a commercial optimization solver.
To use it, you need to register for an account at http://www.gurobi.com/ and request an academic
license. Naturally, this requires you to be a student or staff member at a degree-granting institution.
If you can get hold of a Gurobi license:
``` julia
Pkg.add("Gurobi")
```
*Note: This will fail if you don't have Gurobi installed.*

If you can't get a Gurobi license, then we can use one of the open-source solvers, CBC or GLPK.

**Option 2: CBC.** To install CBC:
``` julia
Pkg.add("Cbc")
```

This will take a while and you'll see lots of gibberish printed on the screen. You need a C compiler, a C++ compiler and Make installed in order to build CBC. If you get error messages complaining about the lack of any of them, exit Julia and run these from the shell:
``` bash
sudo apt-get install gcc
sudo apt-get install g++
sudo apt-get install make
```

Then try again.

**Option 3: GLPK.** To install GLPK, first install the `libgmp-dev` package, from the shell (outside Julia):
``` bash
sudo apt-get install libgmp-dev
```

Then install in Julia:
``` julia
Pkg.add("GLPKMathProgInterface")
```

### User Interface

##### Dependencies

- [Node.js](https://nodejs.org/en/)
- [Bower](http://bower.io)

##### Frontend Setup

- ```cd frontend```
- ```npm install```
- ```bower install```
- ```ember serve --proxy http://0.0.0.0:3000``` (open ```http://localhost:4200/``` to confirm it's working)

Note: the front end requires that there are json files present in ```public/data``` to be imported

##### Backend Setup

- ```cd backend```
- ```npm install```
- ```npm start``` (open ```http://0.0.0.0:3000/``` to confirm it's working)

###### Usage

- To start the server: ```ember s```
- Open ```http://localhost:4200```

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

If you installed more than one of the solvers above, you can choose which one to use with `--solver`. For example, to use GLPK:
``` bash
$ julia trial.jl --solver glpk
```
The other options are `cbc` and `gurobi`. If you don't specify, it'll try Gurobi, then CBC if Gurobi isn't installed, then GLPK if neither of the other two are installed.

GLPK (and Gurobi) supports MIP callbacks and CBC doesn't, and we might want MIP callbacks
in order to pull multiple solutions and have premature termination in there, so I'll probably want
to try harder with GLPK at some point.
