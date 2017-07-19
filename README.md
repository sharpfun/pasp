# rcll-plasp
ASP Planner for RoboCup Logistics League

The RoboCup Logistics League (RCLL) is a league of the annual international robotics competition RoboCup. It focuses on in-factory logistics applications. Following the RoboCup spirit this league’s objective is to enable scientific work in order to achieve a flexible solution of material and informational flow within industrial production using coordinated teams of autonomous mobile robots.

The task of the robots is to fetch raw materials from an input storage, transport them in a dynamic sequences between machines, handling production at these machines, and finally deliver them. A team consists of three robots. Each robot builds on the standardized Festo Robotino robot platform which can be extended with sensors and computing devices.

* Rules and regulations:
http://www.robocup-logistics.org/rules

* Referee Box documentation:
http://www.robocup-logistics.org/refbox

* Rules and regulations ICAPS in simulation:
http://www.robocup-logistics.org/sim-comp

## POPF
Default planner used in ROSPlan, apparently solves only the 1 robot/0 rings problem. Documentation and instructions to build [link](https://nms.kcl.ac.uk/planning/software/popf.html).

### How to use
```bash
./popf rcll_domain_production.pddl 'pddl/problems/incl durations/1 robot/1 order/0 rings.pddl'
```
## PLASP
Translates PDDL to ASP [link](https://github.com/potassco/plasp). Contains encodings which is used to solve planning problems. 
