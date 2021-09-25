# Adjumo
*Allocating Debate Judges Using Mathematical Optimization*

## General information

- A demo of the interface (excluding the allocations solver) is [available here](http://czlee.github.io/adjumo/).
- A report describing challenges involved in using the system at WUDC 2016 is [available here](https://czlee.github.io/adjumo.pdf).

## Getting started

### Julia & Julia Packages

You need to install Julia, and then install a bunch of Julia packages. Julia downloads are at http://julialang.org/downloads/.
Download and install the latest **stable** version, which is currently **0.4.2**.

To install the required packages, run:
``` bash
julia julia/installrequirements.jl [gurobi] [cbc] [glpk] [psql]
```

**If you're not familiar with optimisation solvers, read the below material on the solver libraries first!**

With no arguments, it will install CBC.jl and GLPKMathProgInterface.jl, but not Gurobi.jl or PostgresQL.jl. If any solver (`gurobi`, `cbc`, `glpk`) is specified, it will install only those specified. It will only install PostgreSQL.jl if `psql` is specified. The order of arguments does not matter.

To see what this installs, inspect `installrequirements.jl` (it's a simple enough file).

#### Solvers

There are three options: Gurobi, CBC and GLPK. You only need one of them.

**Option 1: Gurobi.** [Gurobi](http://www.gurobi.com/) is a commercial optimization solver.
You need a license to use it. If you can get hold of a Gurobi license:
``` julia
Pkg.add("Gurobi")
```
*Note: This will fail if you don't have Gurobi installed.*

If you want to use Gurobi Cloud, you need a fork of this repository, since the
official one doesn't yet support Gurobi Cloud:
``` julia
Pkg.clone("https://github.com/czlee/Gurobi.jl.git")
```

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

- To start the server: ```ember serve --proxy http://0.0.0.0:3000 --environment="production" --live-reload false```
- Open ```http://localhost:4200```

## Running

### Julia part only

The file that runs the allocations the Julia part is called `allocate.jl` and can be run directly from the shell:
``` bash
julia allocate.jl
```

This generates random data for a pretend round and runs the algorithm on it. You can run it with a different number of debates, or pretend the current round is something else. For example, to run it with a round comprising 10 debates, pretending it is currently round 3:
``` bash
julia allocate.jl -n 10 -r 3
```

If you installed more than one of the solvers above, you can choose which one to use with `--solver`. For example, to use GLPK:
``` bash
julia allocate.jl --solver glpk
```
The other options are `cbc` and `gurobi`. If you don't specify, it'll try Gurobi, then CBC if Gurobi isn't installed, then GLPK if neither of the other two are installed.

For more options:
``` bash
julia allocate.jl --help
```

## Documentation

Requires ruby, and running:

```bash
  gem install github-pages
```

Then check out the gh-pages branch and run:

```bash
  jekyll s
```
