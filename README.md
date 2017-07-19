# rcll-plasp
ASP Planner for RoboCup Logistics League

* Rules and regulations:
http://www.robocup-logistics.org/rules

* Referee Box documentation:
http://www.robocup-logistics.org/refbox

* Rules and regulations ICAPS in simulation:
http://www.robocup-logistics.org/sim-comp

## POPF
Default planner used in ROSPlan, apparently solves only the 1 robot/0 rings problem. Documentation for popf https://nms.kcl.ac.uk/planning/software/popf.html
. 

### How to use
```bash
./popf rcll_domain_production.pddl 'pddl/problems/incl durations/1 robot/1 order/0 rings.pddl'
```
