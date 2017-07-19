;****************************************************************************
;  rcll_problem_production.pddl: RoboCup Logistics League Production Problem
;
;  Created: Fri Feb 24 23:20:38 2017
;  Copyright  2017  Tim Niemueller [www.niemueller.de]
;****************************************************************************

;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU Library General Public License for more details.
;
;  Read the full text in the LICENSE.GPL file in the doc directory.

(define (problem rcll-production-prob1)
	(:domain rcll-production)

	(:objects
		R-1 - robot
		; If adding R-2 and R-3, also add robot-waiting facts below
		o1 - order
		wp1 - workpiece
		cg1 cg2 cg3 cb1 cb2 cb3 - cap-carrier
		C-BS C-CS1 C-CS2 C-DS C-RS1 C-RS2 - mps
		CYAN - team-color
	)
	 
	(:init
	 (mps-type C-BS BS)
	 (mps-type C-CS1 CS)
	 (mps-type C-CS2 CS)
	 (mps-type C-DS DS)
	 (mps-type C-RS1 RS)
	 (mps-type C-RS2 RS)
	 (location-free START INPUT)
	 (location-free C-BS INPUT)
	 (location-free C-BS OUTPUT)
	 (location-free C-CS1 INPUT)
	 (location-free C-CS1 OUTPUT)
	 (location-free C-CS2 INPUT)
	 (location-free C-CS2 OUTPUT)
	 (location-free C-DS INPUT)
	 (location-free C-DS OUTPUT)
	 (location-free C-RS1 INPUT)
	 (location-free C-RS1 OUTPUT)
	 (location-free C-RS2 INPUT)
	 (location-free C-RS2 OUTPUT)
	 (cs-can-perform C-CS1 CS_RETRIEVE)
	 (cs-can-perform C-CS2 CS_RETRIEVE)
	 (cs-free C-CS1)
	 (cs-free C-CS2)
	 ; Additional base number handling static predicates
	 (rs-sub THREE TWO ONE)
	 (rs-sub THREE ONE TWO)
	 (rs-sub THREE ZERO THREE)
	 (rs-sub TWO TWO ZERO)
	 (rs-sub TWO ONE ONE)
	 (rs-sub TWO ZERO TWO)
	 (rs-sub ONE ONE ZERO)
	 (rs-sub ONE ZERO ONE)
	 (rs-sub ZERO ZERO ZERO)
	 (rs-inc ZERO ONE)
	 (rs-inc ONE TWO)
	 (rs-inc TWO THREE)
	 (rs-filled-with C-RS1 ZERO)
	 (rs-filled-with C-RS2 ZERO)
	 (wp-base-color wp1 BASE_NONE)
	 (wp-cap-color wp1 CAP_NONE)
	 (wp-ring1-color wp1 RING_NONE)
	 (wp-ring2-color wp1 RING_NONE)
	 (wp-ring3-color wp1 RING_NONE)
	 (wp-unused wp1)
	 (robot-waiting R-1)
	 ;(robot-waiting R-2)
	 ;(robot-waiting R-3)
	 (mps-state C-BS IDLE)
 	 (mps-state C-CS1 IDLE)
 	 (mps-state C-CS2 IDLE)
	 (mps-state C-DS IDLE)
 	 (mps-state C-RS1 IDLE)
 	 (mps-state C-RS2 IDLE)

	 (wp-cap-color cg1 CAP_GREY)
	 (wp-cap-color cg2 CAP_GREY)
	 (wp-cap-color cg3 CAP_GREY)
	 (wp-on-shelf cg1 C-CS1 LEFT)
	 (wp-on-shelf cg2 C-CS1 MIDDLE)
	 (wp-on-shelf cg3 C-CS1 RIGHT)

	 (wp-cap-color cb1 CAP_BLACK)
	 (wp-cap-color cb2 CAP_BLACK)
	 (wp-cap-color cb3 CAP_BLACK)
	 (wp-on-shelf cb1 C-CS2 LEFT)
	 (wp-on-shelf cb2 C-CS2 MIDDLE)
	 (wp-on-shelf cb3 C-CS2 RIGHT)

	 (rs-ring-spec C-RS1 RING_GREEN ZERO)
	 (rs-ring-spec C-RS1 RING_YELLOW ZERO)
	 (rs-ring-spec C-RS2 RING_BLUE ONE)
	 (rs-ring-spec C-RS2 RING_ORANGE TWO)

	 ; C0 order
	 ; (order-complexity o1 c0)
	 ; (order-base-color o1 BASE_BLACK)
	 ; (order-cap-color o1 CAP_GREY)
	 ; (order-gate o1 GATE-1)

	 ; C1 order
	 ; (order-complexity o1 c1)
	 ; (order-base-color o1 BASE_BLACK)
	 ; (order-ring1-color o1 RING_GREEN)
	 ; (order-cap-color o1 CAP_GREY)
	 ; (order-gate o1 GATE-1)

	 ; C2 order
	 (order-complexity o1 C2)
	 (order-base-color o1 BASE_BLACK)
	 (order-ring1-color o1 RING_GREEN)
	 ; considerably increases planning time
	 ;(order-ring1-color o1 RING_ORANGE)
	 (order-ring2-color o1 RING_BLUE)
	 (order-cap-color o1 CAP_GREY)
	 (order-gate o1 GATE-1)

	 ; C3 order
	 ; With a yellow second ring (2 additional bases required in total)
	 ; solving here takes 5 seconds, with the blue ring (3 additional
	 ; bases) it runs out of memory (that is with popf 32bit that comes
	 ; ROSPlan)
	 ; (order-complexity o1 C3)
	 ; (order-base-color o1 BASE_BLACK)
	 ; (order-ring1-color o1 RING_GREEN)
	 ; ;(order-ring2-color o1 RING_YELLOW)
	 ; (order-ring2-color o1 RING_BLUE)
	 ; (order-ring3-color o1 RING_ORANGE)
	 ; (order-cap-color o1 CAP_GREY)
	 ; (order-gate o1 GATE-1)
	)

	(:goal (order-fulfilled o1) )
)
