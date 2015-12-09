This directory contains the Julia files for Adjumo.

There is one module, called Adjumo, which will be precompiled the first time code is run.
It comprises the following files: `Adjumo.jl`, `types.jl`, `score.jl` and `display.jl`.
All of these except `display.jl` make up the Adjumo core functionality. `display.jl` 
has a collection of functions for printing information to the console.

All Julia files not included in the Adjumo module are for development and testing purposes
only.

The directory `sandbox` contains files that were used to trial different implementations
of functions for performance benchmarking, as part of performance optimization efforts.
