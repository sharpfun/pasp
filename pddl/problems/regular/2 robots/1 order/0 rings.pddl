(define (problem rcll-production_task)
(:domain rcll-production)
(:objects
    cg1 cg2 cg3 cb1 cb2 cb3 - cap-carrier
    C-BS C-CS1 C-CS2 C-DS C-RS1 C-RS2 - mps
    o1 o7 - order
    R-1 R-2 - robot
    CYAN - team-color
    wp1 - workpiece
)
(:init
    (cs-can-perform C-CS1 CS_RETRIEVE)
    (cs-can-perform C-CS2 CS_RETRIEVE)
    (cs-free C-CS1)
    (cs-free C-CS2)
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
    (mps-state C-RS2 IDLE)
    (mps-state C-RS1 IDLE)
    (mps-state C-CS2 IDLE)
    (mps-state C-CS1 IDLE)
    (mps-state C-BS IDLE)
    (mps-state C-DS IDLE)
    (mps-type C-BS BS)
    (mps-type C-CS1 CS)
    (mps-type C-CS2 CS)
    (mps-type C-DS DS)
    (mps-type C-RS1 RS)
    (mps-type C-RS2 RS)
    (order-base-color o1 BASE_BLACK)
    (order-base-color o7 BASE_RED)
    (order-cap-color o1 CAP_BLACK)
    (order-cap-color o7 CAP_GREY)
    (order-complexity o1 C0)
    (order-complexity o7 C3)
    (order-gate o1 GATE-3)
    (order-gate o7 GATE-1)
    (order-ring1-color o7 RING_ORANGE)
    (order-ring2-color o7 RING_BLUE)
    (order-ring3-color o7 RING_GREEN)
    (robot-waiting R-1)
    (robot-waiting R-2)
    (rs-filled-with C-RS1 ZERO)
    (rs-filled-with C-RS2 ZERO)
    (rs-inc ZERO ONE)
    (rs-inc ONE TWO)
    (rs-inc TWO THREE)
    (rs-ring-spec C-RS1 RING_GREEN ZERO)
    (rs-ring-spec C-RS1 RING_ORANGE ONE)
    (rs-ring-spec C-RS2 RING_BLUE TWO)
    (rs-ring-spec C-RS2 RING_YELLOW ZERO)
    (rs-sub THREE TWO ONE)
    (rs-sub THREE ONE TWO)
    (rs-sub THREE ZERO THREE)
    (rs-sub TWO TWO ZERO)
    (rs-sub TWO ONE ONE)
    (rs-sub TWO ZERO TWO)
    (rs-sub ONE ONE ZERO)
    (rs-sub ONE ZERO ONE)
    (rs-sub ZERO ZERO ZERO)
    (wp-base-color wp1 BASE_NONE)
    (wp-cap-color wp1 CAP_NONE)
    (wp-cap-color cg1 CAP_GREY)
    (wp-cap-color cg2 CAP_GREY)
    (wp-cap-color cg3 CAP_GREY)
    (wp-cap-color cb1 CAP_BLACK)
    (wp-cap-color cb2 CAP_BLACK)
    (wp-cap-color cb3 CAP_BLACK)
    (wp-on-shelf cg1 C-CS1 LEFT)
    (wp-on-shelf cg2 C-CS1 MIDDLE)
    (wp-on-shelf cg3 C-CS1 RIGHT)
    (wp-on-shelf cb1 C-CS2 LEFT)
    (wp-on-shelf cb2 C-CS2 MIDDLE)
    (wp-on-shelf cb3 C-CS2 RIGHT)
    (wp-ring1-color wp1 RING_NONE)
    (wp-ring2-color wp1 RING_NONE)
    (wp-ring3-color wp1 RING_NONE)
    (wp-unused wp1)
)
(:goal (and
    (order-fulfilled o1)
)))
