To do
=====
Add semantic information about chair to panel, create a Panel class, one that
relies on integers and a different more friendly one that involves Adjudicators.

Change "force" to "lock".

Variables
=========
`X[d,p]` (nd by np) is 1 if panel `p` is assigned to debate `d`, and 0 if not.
`Σ[d,p]` (nd by np) is the score when assigning panel `p` to debate `d`.
`Q[p,a]` (np by na) is 1 if panel `p` contains adjudicator `a`, and 0 if not.

`(Σ.*X)[d,p]` (nd by np) are the scores for the assigned panels, 0 if not assigned.
`(X*1)[d]`    (nd by 1)  is the number of panels assigned to debate `d`.
`1'*X[p]`     (1 by np)  is the number of debates assigned to panel `p`.
`(X*Q)[d,a]`  (nd by na) is the number of times adjudicator `a` is assigned to debate `d`.
`(1*X*Q)[a]`  (1 by na)  is the number of times adjudicator `a` is assigned.


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

