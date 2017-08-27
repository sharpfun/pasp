;****************************************************************************
;  rcll_domain_production.pddl: RoboCup Logistics League Production Model
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

(define (domain rcll-production-durative)
	(:requirements :strips :typing :durative-actions :numeric-fluents)

	(:types
		robot - object
		team-color - object
		location - object
		mps - location
		mps-typename - object
		mps-statename - object
		mps-side - object
		base-color - object
		product-base-color - base-color
		cap-color - object
		product-cap-color - cap-color
		ring-color - object
		product-ring-color - ring-color
		ds-gate - object
		cs-operation - object
		cs-statename - object
		order - object
    order-complexity-value - object
		workpiece - object
		cap-carrier - workpiece
		shelf-spot - object
		ring-num - object
	)

	(:constants
		START - location
		BS CS DS RS - mps-typename
		IDLE BROKEN PREPARED PROCESSING PROCESSED WAIT-IDLE READY-AT-OUTPUT DOWN - mps-statename
		INPUT OUTPUT - mps-side
		BASE_NONE - base-color
		BASE_RED BASE_BLACK BASE_SILVER - product-base-color
		CAP_NONE - cap-color
		CAP_BLACK CAP_GREY - product-cap-color
		GATE-1 GATE-2 GATE-3 - ds-gate
		RING_NONE - ring-color
		RING_BLUE RING_GREEN RING_ORANGE RING_YELLOW - product-ring-color
		CS_RETRIEVE CS_MOUNT - cs-operation
		C0 C1 C2 C3 - order-complexity-value
		LEFT MIDDLE RIGHT - shelf-spot
		ZERO ONE TWO THREE - ring-num
	)

	(:predicates
		(at ?r - robot ?m - location ?side - mps-side)
		(holding ?r - robot ?wp - workpiece)
		(can-hold ?r - robot)
		(entered-field ?r - robot)
		(location-free ?l - location ?side - mps-side)
		(robot-waiting ?r - robot)
		(mps-type ?m - mps ?t - mps-typename)
		(mps-state ?m - mps ?s - mps-statename)
		(bs-prepared-color ?m - mps ?col - product-base-color)
		(bs-prepared-side ?m - mps ?side - mps-side)
		(rs-ring-spec ?m - mps ?r - product-ring-color ?rn - ring-num)
		(cs-can-perform ?m - mps ?op - cs-operation)
		(cs-prepared-for ?m - mps ?op - cs-operation)
		(cs-buffered ?m - mps ?col - cap-color)
		(cs-free ?m - mps)
		(rs-prepared-color ?m - mps ?col - product-ring-color)
		(rs-filled-with ?m - mps ?n - ring-num)
		(ds-prepared-gate ?m - mps ?g - ds-gate)
		; These must be static predicates stating the legal ring-num operations
		(rs-sub ?minuend ?subtrahend ?difference - ring-num)
		(rs-inc ?summand ?sum - ring-num)
		(order-complexity ?ord - order ?com - order-complexity-value)
		(order-base-color ?ord - order ?col - product-base-color)
		(order-ring1-color ?ord - order ?col - product-ring-color)
		(order-ring2-color ?ord - order ?col - product-ring-color)
		(order-ring3-color ?ord - order ?col - product-ring-color)
		(order-cap-color ?ord - order ?col - product-cap-color)
		(order-fulfilled ?ord - order)
		(order-gate ?ord - order ?gate - ds-gate)
		(wp-unused ?wp - workpiece)
		(wp-usable ?wp - workpiece)
		(wp-at ?wp - workpiece ?m - mps ?side - mps-side)
		(wp-base-color ?wp - workpiece ?col - base-color)
		(wp-ring1-color ?wp - workpiece ?col - ring-color)
		(wp-ring2-color ?wp - workpiece ?col - ring-color)
		(wp-ring3-color ?wp - workpiece ?col - ring-color)
		(wp-cap-color ?wp - workpiece ?col - cap-color)
		(wp-on-shelf ?wp - workpiece ?m - mps ?spot - shelf-spot)
	)

	(:functions
		;(path-length ?from - location ?from-side - mps-side ?to - location ?to-side - mps-side)
		(order-delivery-begin ?ord - order)
		(order-delivery-end   ?ord - order)
	)

	; The following static predicates are required in the problem
  ; to properly handle additional bases:
	; (rs-sub THREE TWO ONE)
	; (rs-sub THREE ONE TWO)
	; (rs-sub THREE ZERO THREE)
	; (rs-sub TWO TWO ZERO)
	; (rs-sub TWO ONE ONE)
	; (rs-sub TWO ZERO TWO)
	; (rs-sub ONE ONE ZERO)
	; (rs-sub ONE ZERO ONE)
	; (rs-sub ZERO ZERO ZERO)
	; (rs-inc ZERO ONE)
	; (rs-inc ONE TWO)
	; (rs-inc TWO THREE)

	; prepare base station; change state from IDLE to PROCESSING and create product base with specified color to mps-side which is OUTPUT
	(:action prepare-bs
		:parameters (?m - mps ?side - mps-side ?bc - product-base-color)
		:precondition (and (mps-type ?m BS) (mps-state ?m IDLE))
		:effect (and (not (mps-state ?m IDLE)) (mps-state ?m PROCESSING)
								 (bs-prepared-color ?m ?bc) (bs-prepared-side ?m ?side))
	)

	; prepare delivery station; change state from IDLE to PREPARED and prepare specific ds-gate: GATE-1, GATE-2, GATE-3
	(:action prepare-ds
		:parameters (?r - robot ?m - mps ?gate - ds-gate)
		:precondition (and (at ?r ?m INPUT) (mps-type ?m DS) (mps-state ?m IDLE))
		:effect (and (not (mps-state ?m IDLE)) (mps-state ?m PREPARED) (ds-prepared-gate ?m ?gate))
	)

	; prepare cap station; change state from IDLE to PREPARED, cs-can-perform CS_RETRIEVE or CS_MOUNT -> cs-prepared-for CS_RETRIEVE or CS_MOUNT
	; CS_RETRIEVE - robot must use workpiece with cap and handle in cap station (cs-buffered ?mps ?capcol)
	; CS_MOUNT - cap will be mounted on workpiece
	; ??????? Why robot here in parameters? must be at input of mps
	(:action prepare-cs
		:parameters (?r - robot ?m - mps ?op - cs-operation)
		:precondition (and (at ?r ?m INPUT) (mps-type ?m CS) (mps-state ?m IDLE) (cs-can-perform ?m ?op))
		:effect (and (not (mps-state ?m IDLE)) (mps-state ?m PREPARED)
								 (not (cs-can-perform ?m ?op)) (cs-prepared-for ?m ?op))
	)

	; workpiece base is ready to pickup; follows prepare-bs and create wp-at, wp-usable, mps-state READY-AT-OUTPUT
	(:action bs-dispense
		:parameters (?m - mps ?side - mps-side ?wp - workpiece ?basecol - product-base-color)
		:precondition (and (mps-type ?m BS) (mps-state ?m PROCESSING)
											 (bs-prepared-color ?m ?basecol) (bs-prepared-side ?m ?side)
											 (wp-base-color ?wp BASE_NONE) (wp-unused ?wp))
		:effect (and (wp-at ?wp ?m ?side)
								 (not (bs-prepared-color ?m ?basecol)) (not (bs-prepared-side ?m ?side))
								 (not (wp-base-color ?wp BASE_NONE)) (wp-base-color ?wp ?basecol)
								 (not (wp-unused ?wp)) (wp-usable ?wp)
								 (not (mps-state ?m PROCESSING)) (mps-state ?m READY-AT-OUTPUT))
	)

	; cap station mounts cap on workpiece; creates cs-can-perform CS_RETRIEVE, wp-at OUTPUT, mps-state READY-AT-OUTPUT
	; CS_MOUNT - cap will be mounted on workpiece
	(:durative-action cs-mount-cap
		:parameters (?m - mps ?wp - workpiece ?capcol - cap-color)
		:duration (= ?duration 0)
		:condition (and (at start (mps-type ?m CS)) (at start (mps-state ?m PROCESSING))
										(at start (cs-buffered ?m ?capcol)) (at start (cs-prepared-for ?m CS_MOUNT))
										(at start (wp-usable ?wp)) (at start (wp-at ?wp ?m INPUT))
										(at start (wp-cap-color ?wp CAP_NONE)))
		:effect (and (at start (not (mps-state ?m PROCESSING))) (at end (mps-state ?m READY-AT-OUTPUT))
								 (at start (not (wp-at ?wp ?m INPUT))) (at end (wp-at ?wp ?m OUTPUT))
								 (at end (not (wp-cap-color ?wp CAP_NONE))) (at end (wp-cap-color ?wp ?capcol))
								 (at end (cs-can-perform ?m CS_RETRIEVE)))
	)

	; CS_RETRIEVE - robot must use workpiece with cap and handle in cap station to have (cs-buffered ?mps ?capcol)
	(:durative-action cs-retrieve-cap
		:parameters (?m - mps ?cc - cap-carrier ?capcol - cap-color)
		:duration (= ?duration 0)
		:condition (and (at start (mps-type ?m CS)) (at start (mps-state ?m PROCESSING))
										(at start (cs-prepared-for ?m CS_RETRIEVE))
										(at start (wp-at ?cc ?m INPUT))  (at start (wp-cap-color ?cc ?capcol)))
		:effect (and (at start (not (mps-state ?m PROCESSING))) (at end (mps-state ?m READY-AT-OUTPUT))
                                 (at start (not (wp-at ?cc ?m INPUT))) (at end (wp-at ?cc ?m OUTPUT))
                                 (at start (not (wp-cap-color ?cc ?capcol))) (at end (wp-cap-color ?cc CAP_NONE))
                                 (at end (cs-buffered ?m ?capcol)) (at end (cs-can-perform ?m CS_MOUNT)))
	)
	
	; ring stations' rings are limited ZERO ONE TWO THREE - ring-num
	; prepare ring station to mount [?r-req - ring-num] amount of rings with specific [?rc - product-ring-color] color
	; (rs-ring-spec ?m ?rc ?r-req) - ring station which supports specific color requires ?r-res bases to produce one ring of specific color
	; (rs-filled-with ?m ?rs-before) - amount of bases ring station has
	(:action prepare-rs
		:parameters (?r - robot ?m - mps ?rc - product-ring-color ?rs-before ?rs-after ?r-req - ring-num)
		:precondition (and (at ?r ?m INPUT) (mps-type ?m RS) (mps-state ?m IDLE) (rs-ring-spec ?m ?rc ?r-req)
											 (rs-filled-with ?m ?rs-before) (rs-sub ?rs-before ?r-req ?rs-after))
		:effect (and (not (mps-state ?m IDLE)) (mps-state ?m PREPARED)
								 (rs-prepared-color ?m ?rc))
	)

	; ring station mounts ring on workpiece at the top of the base (ring1)
	; must be no cap, and RING_NONE at ring1 workpiece position 
	; difference with others conditions: (wp-ring1-color ?wp RING_NONE) (wp-cap-color ?wp CAP_NONE) 
	(:durative-action rs-mount-ring1
		:parameters (?m - mps ?wp - workpiece ?col - product-ring-color ?rs-before ?rs-after ?r-req - ring-num)
		:duration (= ?duration 0)				 
		:condition (and (at start (mps-type ?m RS)) (at start (mps-state ?m PROCESSING))
										(at start (wp-at ?wp ?m INPUT)) (at start (wp-usable ?wp))
										(at start (wp-ring1-color ?wp RING_NONE))
										(at start (wp-cap-color ?wp CAP_NONE))
										(at start (rs-prepared-color ?m ?col))
										(at start (rs-ring-spec ?m ?col ?r-req))
										(at start (rs-filled-with ?m ?rs-before))
										(at start (rs-sub ?rs-before ?r-req ?rs-after)))
		:effect (and (at end (not (mps-state ?m PROCESSING))) (at end (mps-state ?m READY-AT-OUTPUT))
								 (at end (not (rs-prepared-color ?m ?col)))
								 (at start (not (wp-at ?wp ?m INPUT))) (at end (wp-at ?wp ?m OUTPUT))
								 (at end (not (wp-ring1-color ?wp RING_NONE))) (at end (wp-ring1-color ?wp ?col))
								 (at start (not (rs-filled-with ?m ?rs-before))) (at end (rs-filled-with ?m ?rs-after)))
	)

	; ring station mounts ring on top of workpiece on the ring2 position
	; must be no cap, and RING_NONE at ring2 workpiece position, some color on ring1
	; difference with others conditions: (wp-ring1-color ?wp ?col1) (wp-ring2-color ?wp RING_NONE) (wp-cap-color ?wp CAP_NONE)  
	(:durative-action rs-mount-ring2
		:parameters (?m - mps ?wp - workpiece ?col - product-ring-color ?col1 - product-ring-color
		             ?rs-before ?rs-after ?r-req - ring-num)
		:duration (= ?duration 0)				 
		:condition (and (at start (mps-type ?m RS)) (at start (mps-state ?m PROCESSING))
										(at start (wp-at ?wp ?m INPUT)) (at start (wp-usable ?wp))
										(at start (wp-ring1-color ?wp ?col1))
										(at start (wp-ring2-color ?wp RING_NONE))
										(at start (wp-cap-color ?wp CAP_NONE))
										(at start (rs-prepared-color ?m ?col))
										(at start (rs-ring-spec ?m ?col ?r-req))
										(at start (rs-filled-with ?m ?rs-before))
										(at start (rs-sub ?rs-before ?r-req ?rs-after)))
		:effect (and (at end (not (mps-state ?m PROCESSING))) (at end (mps-state ?m READY-AT-OUTPUT))
								 (at end (not (rs-prepared-color ?m ?col)))
								 (at start (not (wp-at ?wp ?m INPUT))) (at end (wp-at ?wp ?m OUTPUT))
								 (at end (not (wp-ring2-color ?wp RING_NONE))) (at end (wp-ring2-color ?wp ?col))
								 (at start (not (rs-filled-with ?m ?rs-before))) (at end (rs-filled-with ?m ?rs-after)))
	)

	; ring station mounts ring on top of workpiece on the ring3 position
	; must be no cap, and RING_NONE at ring2/ring1 workpiece position, some color on ring3
	; difference with others conditions: (wp-ring1-color ?wp ?col1) (wp-ring2-color ?wp ?col2) (wp-ring3-color ?wp RING_NONE) (wp-cap-color ?wp CAP_NONE) 
	(:durative-action rs-mount-ring3
		:parameters (?m - mps ?wp - workpiece ?col - product-ring-color  ?col1 ?col2 - product-ring-color
		             ?rs-before ?rs-after ?r-req - ring-num)
		:duration (= ?duration 0)				 
		:condition (and (at start (mps-type ?m RS)) (at start (mps-state ?m PROCESSING))
										(at start (wp-at ?wp ?m INPUT)) (at start (wp-usable ?wp))
										(at start (wp-ring1-color ?wp ?col1))
										(at start (wp-ring2-color ?wp ?col2))
										(at start (wp-ring3-color ?wp RING_NONE))
										(at start (wp-cap-color ?wp CAP_NONE))
										(at start (rs-prepared-color ?m ?col))
										(at start (rs-ring-spec ?m ?col ?r-req))
										(at start (rs-filled-with ?m ?rs-before))
										(at start (rs-sub ?rs-before ?r-req ?rs-after)))
		:effect (and (at end (not (mps-state ?m PROCESSING))) (at end (mps-state ?m READY-AT-OUTPUT))
								 (at end (not (rs-prepared-color ?m ?col)))
								 (at start (not (wp-at ?wp ?m INPUT))) (at end (wp-at ?wp ?m OUTPUT))
								 (at end (not (wp-ring3-color ?wp RING_NONE))) (at end (wp-ring3-color ?wp ?col))
								 (at start (not (rs-filled-with ?m ?rs-before))) (at end (rs-filled-with ?m ?rs-after)))
	)

	; The following is the generic move version.
	; It takes the robot from any location (at any side) to any MPS (any side).
	; However, this also creates a tremendous number of options during search and
	; hence is detrimental for planning performance.
	;
	; (:durative-action move
	; 	:parameters (?r - robot ?from - location ?from-side - mps-side ?to - mps ?to-side - mps-side)
	;		:duration (= ?duration (path-length ?from ?from-side ?to ?to-side))
	; 	:condition (and (at start (entered-field ?r))
	; 									(at start (at ?r ?from ?from-side))
	; 									(at start (location-free ?to ?to-side)))
	; 	:effect (and (at start (not (at ?r ?from ?from-side)))
	; 							 (at start (location-free ?from ?from-side))
	; 							 (at start (not (location-free ?to ?to-side)))
	; 							 (at end (at ?r ?to ?to-side)))
	; )

	; Move actions specific for the expected follow-up action.
	; This models the move in two versions specific to the expected next action,
	; either the retrieval or the delivery of a workpiece. While a more generic
	; such as the one would be desirable, in typical test cases these specific
	; actions cut the planning time by about 95%.
	(:durative-action move-wp-put-at-input
		:parameters (?r - robot ?from - location ?from-side - mps-side ?to - mps)
	;	:duration (= ?duration (path-length ?from ?from-side ?to INPUT))
		:duration (= ?duration 0)
		:condition (and (at start (entered-field ?r))
										(at start (at ?r ?from ?from-side))
										(at start (location-free ?to INPUT))
										(at start (mps-state ?to IDLE)))
		:effect (and (at start (not (at ?r ?from ?from-side)))
								 (at start (location-free ?from ?from-side))
								 (at start (not (location-free ?to INPUT)))
								 (at end (at ?r ?to INPUT)))
	)

	; robot moves ?from - mps with free holder to the INPUT of ?to - mps which has status READY-AT-OUTPUT
	; !!!!! :duration (= ?duration (path-length ?from ?from-side ?to ?to-side))
	(:durative-action move-wp-get
		:parameters (?r - robot ?from - location ?from-side - mps-side ?to - mps ?to-side - mps-side)
	;	:duration (= ?duration (path-length ?from ?from-side ?to ?to-side))
		:duration (= ?duration 0)
		:condition (and (at start (entered-field ?r))
										(at start (at ?r ?from ?from-side))
										(at start (location-free ?to ?to-side))
										(at start (mps-state ?to READY-AT-OUTPUT))
										(at start (can-hold ?r)))
		:effect (and (at start (not (at ?r ?from ?from-side)))
								 (at start (location-free ?from ?from-side))
								 (at start (not (location-free ?to ?to-side)))
								 (at end (at ?r ?to ?to-side)))
	)

	; robot goes to START position (no mps)
	(:durative-action enter-field
		:parameters (?r - robot ?team-color - team-color)
		:duration (= ?duration 10)
		:condition (and (at start (location-free START INPUT))
										(at start (robot-waiting ?r)))
		:effect (and (at end (entered-field ?r))
								 (at end (at ?r START INPUT))
								 (at start (not (location-free START INPUT)))
								 (at end (not (robot-waiting ?r))) (at end (can-hold ?r)))
	)

	; destroy cap carrier
	(:action wp-discard
		:parameters (?r - robot ?cc - cap-carrier)
		:precondition (and (holding ?r ?cc))
		:effect (and (not (holding ?r ?cc)) (not (wp-usable ?cc)) (can-hold ?r))
	)

	; get cap-carrier workpiece from shelf of cap station from ?spot
	(:durative-action wp-get-shelf
		:parameters (?r - robot ?cc - cap-carrier ?m - mps ?spot - shelf-spot)
	 	:duration (= ?duration 20)
		:condition (and (at start (at ?r ?m INPUT)) (at start (wp-on-shelf ?cc ?m ?spot)) (at start (can-hold ?r)))
		:effect (and (at end (holding ?r ?cc)) (at start (not (can-hold ?r)))
								 (at start (not (wp-on-shelf ?cc ?m ?spot))) (at end (wp-usable ?cc)))
	)

	; robot gets workpiece from mps at specific side and holds it, mps-state must be READY-AT-OUTPUT
	(:durative-action wp-get
		:parameters (?r - robot ?wp - workpiece ?m - mps ?side - mps-side)
		:duration (= ?duration 10)
		:condition (and (at start (at ?r ?m ?side)) (at start (can-hold ?r)) (at start (wp-at ?wp ?m ?side))
										(at start (mps-state ?m READY-AT-OUTPUT)) (at start (wp-usable ?wp)))
		:effect (and (at end (not (wp-at ?wp ?m ?side))) (at end (holding ?r ?wp)) (at start (not (can-hold ?r)))
								 (at start (not (mps-state ?m READY-AT-OUTPUT))) (at end (mps-state ?m IDLE)))
	)

	; put workpiece to mps with state PREPARED > PROCESSING
	(:durative-action wp-put
		:parameters (?r - robot ?wp - workpiece ?m - mps)
		:duration (= ?duration 10)
		:condition (and (at start (at ?r ?m INPUT)) (at start (mps-state ?m PREPARED))
										(at start (wp-usable ?wp)) (at start (holding ?r ?wp)))
		:effect (and (at end (wp-at ?wp ?m INPUT)) (at start (not (holding ?r ?wp))) (at end (can-hold ?r))
								 (at start (not (mps-state ?m PREPARED))) (at end (mps-state ?m PROCESSING)))
	)

	; robot put bases required to make ring with specific color described in rs-ring-spec to ring station
	(:durative-action wp-put-slide-cc
		:parameters (?r - robot ?wp - cap-carrier ?m - mps ?rs-before ?rs-after - ring-num)
		:duration (= ?duration 0)
		:condition (and (at start (mps-type ?m RS)) (at start (at ?r ?m INPUT))
										(at start (wp-usable ?wp)) (at start (holding ?r ?wp))
										(at start (rs-filled-with ?m ?rs-before))
										(at start (rs-inc ?rs-before ?rs-after)))
		:effect (and (at end (not (wp-usable ?wp))) (at start (not (holding ?r ?wp))) (at end (can-hold ?r))
								 (at end (not (rs-filled-with ?m ?rs-before))) (at end (rs-filled-with ?m ?rs-after)))
	)

	; (:durative-action wp-put-slide-empty-base
	; 	:parameters (?r - robot ?wp - workpiece ?m - mps ?rs-before ?rs-after - ring-num)
	; 	:duration (= ?duration 0)
	; 	:condition (and (at start (mps-type ?m RS)) (at start (at ?r ?m INPUT))
	; 									(at start (wp-usable ?wp)) (at start (holding ?r ?wp))
	; 									(at start (wp-ring1-color ?wp RING_NONE))
	; 									(at start (wp-ring2-color ?wp RING_NONE))
	; 									(at start (wp-ring3-color ?wp RING_NONE))
	; 									(at start (wp-cap-color ?wp CAP_NONE))
	; 									(at start (rs-filled-with ?m ?rs-before))
	; 									(at start (rs-inc ?rs-before ?rs-after)))
	; 	:effect (and (at end (not (wp-usable ?wp))) (at start (not (holding ?r ?wp))) (at end (can-hold ?r))
	; 							 (at end (not (rs-filled-with ?m ?rs-before))) (at end (rs-filled-with ?m ?rs-after)))
	; )

	; done by delivery station, verifies that order is delivered properly, colors are correct, complexity 0 - base, 0 rings, cap
	(:action fulfill-order-c0
		:parameters (?ord - order ?wp - workpiece ?m - mps ?g - ds-gate
		             ?basecol - product-base-color ?capcol - product-cap-color)
		:precondition (and (wp-at ?wp ?m INPUT) (wp-usable ?wp)
											 (mps-type ?m DS) (mps-state ?m PROCESSING) (ds-prepared-gate ?m ?g)
											 (order-complexity ?ord C0) (order-gate ?ord ?g)
											 (order-base-color ?ord ?basecol) (wp-base-color ?wp ?basecol)
											 (order-cap-color ?ord ?capcol) (wp-cap-color ?wp ?capcol)
											 (wp-ring1-color ?wp RING_NONE) (wp-ring2-color ?wp RING_NONE) (wp-ring3-color ?wp RING_NONE))
		:effect (and (order-fulfilled ?ord) (not (wp-at ?wp ?m INPUT)) (not  (ds-prepared-gate ?m ?g))
								 (not (wp-base-color ?wp ?basecol)) (not (wp-cap-color ?wp ?capcol)))
								 
	)

	; done by delivery station, verifies that order is delivered properly, colors are correct, complexity 1 - base, 1 ring, cap
	(:action fulfill-order-c1
		:parameters (?ord - order ?wp - workpiece ?m - mps ?g - ds-gate
		             ?basecol - product-base-color ?capcol - product-cap-color
		             ?ring1col - product-ring-color)

		:precondition (and (wp-at ?wp ?m INPUT) (wp-usable ?wp)
											 (mps-type ?m DS) (mps-state ?m PROCESSING) (ds-prepared-gate ?m ?g)
											 (order-complexity ?ord C1) (order-gate ?ord ?g)
											 (order-base-color ?ord ?basecol) (wp-base-color ?wp ?basecol)
											 (order-ring1-color ?ord ?ring1col) (wp-ring1-color ?wp ?ring1col)
											 (order-cap-color ?ord ?capcol) (wp-cap-color ?wp ?capcol))
		:effect (and (order-fulfilled ?ord) (not (wp-at ?wp ?m INPUT)) (not (ds-prepared-gate ?m ?g))
								 (not (wp-base-color ?wp ?basecol)) (not (wp-cap-color ?wp ?capcol)))
	)

	; done by delivery station, verifies that order is delivered properly, colors are correct, complexity 2 - base, 2 rings, cap
	(:action fulfill-order-c2
		:parameters (?ord - order ?wp - workpiece ?m - mps ?g - ds-gate
		             ?basecol - product-base-color ?capcol - product-cap-color
		             ?ring1col ?ring2col - product-ring-color)

		:precondition (and (wp-at ?wp ?m INPUT) (wp-usable ?wp)
											 (mps-type ?m DS) (mps-state ?m PROCESSING) (ds-prepared-gate ?m ?g)
											 (order-complexity ?ord C2) (order-gate ?ord ?g)
											 (order-base-color ?ord ?basecol) (wp-base-color ?wp ?basecol)
											 (order-ring1-color ?ord ?ring1col) (wp-ring1-color ?wp ?ring1col)
											 (order-ring2-color ?ord ?ring2col) (wp-ring2-color ?wp ?ring2col)
											 (wp-ring3-color ?wp RING_NONE)
											 (order-cap-color ?ord ?capcol) (wp-cap-color ?wp ?capcol))
		:effect (and (order-fulfilled ?ord) (not (wp-at ?wp ?m INPUT)) (not  (ds-prepared-gate ?m ?g))
								 (not (wp-base-color ?wp ?basecol)) (not (wp-cap-color ?wp ?capcol)))
								 
	)

	; done by delivery station, verifies that order is delivered properly, colors are correct, complexity 3 - base, 3 rings, cap
	(:action fulfill-order-c3
		:parameters (?ord - order ?wp - workpiece ?m - mps ?g - ds-gate
		             ?basecol - product-base-color ?capcol - product-cap-color
		             ?ring1col ?ring2col ?ring3col - product-ring-color)

		:precondition (and (wp-at ?wp ?m INPUT) (wp-usable ?wp)
											 (mps-type ?m DS) (mps-state ?m PROCESSING) (ds-prepared-gate ?m ?g)
											 (order-complexity ?ord C3) (order-gate ?ord ?g)
											 (order-base-color ?ord ?basecol) (wp-base-color ?wp ?basecol)
											 (order-ring1-color ?ord ?ring1col) (wp-ring1-color ?wp ?ring1col)
											 (order-ring2-color ?ord ?ring2col) (wp-ring2-color ?wp ?ring2col)
											 (order-ring3-color ?ord ?ring3col) (wp-ring3-color ?wp ?ring3col)
											 (order-cap-color ?ord ?capcol) (wp-cap-color ?wp ?capcol)
											 )
		:effect (and (order-fulfilled ?ord) (not (wp-at ?wp ?m INPUT)) (not (ds-prepared-gate ?m ?g))
								 (not (wp-base-color ?wp ?basecol)) (not (wp-cap-color ?wp ?capcol)))
	)
)
