Information required by the system
==================================
 - Meta-information
    - What factor(s) are taken into account

 - Judges, and their
    - Names (for display)
    - Institutions
    - Rankings
    - Gender(s)
    - Region(s)
    - Language status(es)
 - Teams, and their
    - Names (for display)
    - Institutions
    - Gender(?)
    - Region
    - Language status
 - The draw
 - Teams that judges have seen, and in which rounds
 - Judges that judges have paneled with, and in which rounds
 - Teams that judges conflict with, and to what degrees
 - Judges that judges conflict with, and to what degrees

The Julia back-end does not require names but requires everything else.

Julia
Modules
    1. Score function calculator
        a. Debate weighting calculator
        b. Calculators for each thing
    2. Set of possible panels generator
    3. Solver wrapper

Questions about the solver
 - Can it retain multiple solutions?
 - Can it use previous solutions to find related solutions?
 - Can a solver be stopped and asked for whatever it has at the time?

Web interface

