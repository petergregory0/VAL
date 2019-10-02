(define (domain powerdrive-verbatim)

(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

(:types 
    tool
    location
    state
)

(:constants 
	fxd-pendingassemblystate transferred-permanentstate rong-failedunderanalysisstate onlocation-transittobasestate onlocation-onlocationstate rong-underservicestate rong-failedstate fxd-assembledstate in-transitstate fxd-wopendingstate rite-rffstate rong-usedstate fxd-underservicestate onlocation-transittorigstate rite-inprocessstate transferred-repairstate rong-repairstate fxd-pendingapprovalstate transferred-loanedstate in-transitstate - state
)

(:predicates ;todo: define predicates here
    (at    ?t - tool ?l - location)
    (state ?t - tool ?s - state)
)


(:functions 
    (number-of-tools-at       ?l - location)
    (number-of-tools-in-state ?s - state)
    
)

;In Transit Actions
    (:durative-action in-transit
        :parameters (?t - tool ?l1 ?l2 - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l1))
        )
        :effect (and 
            (at start (state ?t in-transitstate))
            (at end   (not (state ?t in-transitstate)))
            (at start (not (at ?t ?l1)))
            (at end   (at ?t ?l2))
            (at start (decrease (number-of-tools-at ?l1) 1))
            (at end   (increase (number-of-tools-at ?l2) 1))
            (at start (increase (number-of-tools-in-state in-transitstate) 1))
            (at end   (decrease (number-of-tools-in-state in-transitstate) 1))
            ;; (at start (increase (number-of-tools-in-state-in-transit) 1))
            ;; (at end   (decrease (number-of-tools-in-state-in-transit) 1))
        )
    )

;Stateful Actions
    (:durative-action fxd-pendingassembly
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t fxd-pendingassemblystate))
            (at end   (not (state ?t fxd-pendingassemblystate)))
            (at start (increase (number-of-tools-in-state fxd-pendingassemblystate) 1))
            (at end   (decrease (number-of-tools-in-state fxd-pendingassemblystate) 1))
            (at start (increase (number-of-tools-in-state-location fxd-pendingassemblystate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location fxd-pendingassemblystate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-fxd-pendingassembly) 1))
            ;; (at end   (decrease (number-of-tools-in-state-fxd-pendingassembly) 1))
        )
    )

    (:durative-action transferred-permanent
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t transferred-permanentstate))
            (at end   (not (state ?t transferred-permanentstate)))
            (at start (increase (number-of-tools-in-state transferred-permanentstate) 1))
            (at end   (decrease (number-of-tools-in-state transferred-permanentstate) 1))
            (at start (increase (number-of-tools-in-state-location transferred-permanentstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location transferred-permanentstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-transferred-permanent) 1))
            ;; (at end   (decrease (number-of-tools-in-state-transferred-permanent) 1))
        )
    )

    (:durative-action rong-failedunderanalysis
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rong-failedunderanalysisstate))
            (at end   (not (state ?t rong-failedunderanalysisstate)))
            (at start (increase (number-of-tools-in-state rong-failedunderanalysisstate) 1))
            (at end   (decrease (number-of-tools-in-state rong-failedunderanalysisstate) 1))
            (at start (increase (number-of-tools-in-state-location rong-failedunderanalysisstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rong-failedunderanalysisstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rong-failedunderanalysis) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rong-failedunderanalysis) 1))
        )
    )

    (:durative-action onlocation-transittobase
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t onlocation-transittobasestate))
            (at end   (not (state ?t onlocation-transittobasestate)))
            (at start (increase (number-of-tools-in-state onlocation-transittobasestate) 1))
            (at end   (decrease (number-of-tools-in-state onlocation-transittobasestate) 1))
            (at start (increase (number-of-tools-in-state-location onlocation-transittobasestate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location onlocation-transittobasestate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-onlocation-transittobase) 1))
            ;; (at end   (decrease (number-of-tools-in-state-onlocation-transittobase) 1))
        )
    )

    (:durative-action onlocation-onlocation
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t onlocation-onlocationstate))
            (at end   (not (state ?t onlocation-onlocationstate)))
            (at start (increase (number-of-tools-in-state onlocation-onlocationstate) 1))
            (at end   (decrease (number-of-tools-in-state onlocation-onlocationstate) 1))
            (at start (increase (number-of-tools-in-state-location onlocation-onlocationstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location onlocation-onlocationstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-onlocation-onlocation) 1))
            ;; (at end   (decrease (number-of-tools-in-state-onlocation-onlocation) 1))
        )
    )

    (:durative-action rong-underservice
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rong-underservicestate))
            (at end   (not (state ?t rong-underservicestate)))
            (at start (increase (number-of-tools-in-state rong-underservicestate) 1))
            (at end   (decrease (number-of-tools-in-state rong-underservicestate) 1))
            (at start (increase (number-of-tools-in-state-location rong-underservicestate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rong-underservicestate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rong-underservice) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rong-underservice) 1))
        )
    )

    (:durative-action rong-failed
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rong-failedstate))
            (at end   (not (state ?t rong-failedstate)))
            (at start (increase (number-of-tools-in-state rong-failedstate) 1))
            (at end   (decrease (number-of-tools-in-state rong-failedstate) 1))
            (at start (increase (number-of-tools-in-state-location rong-failedstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rong-failedstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rong-failed) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rong-failed) 1))
        )
    )

    (:durative-action fxd-assembled
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t fxd-assembledstate))
            (at end   (not (state ?t fxd-assembledstate)))
            (at start (increase (number-of-tools-in-state fxd-assembledstate) 1))
            (at end   (decrease (number-of-tools-in-state fxd-assembledstate) 1))
            (at start (increase (number-of-tools-in-state-location fxd-assembledstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location fxd-assembledstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-fxd-assembled) 1))
            ;; (at end   (decrease (number-of-tools-in-state-fxd-assembled) 1))
        )
    )

    (:durative-action in-transit
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t in-transitstate))
            (at end   (not (state ?t in-transitstate)))
            (at start (increase (number-of-tools-in-state in-transitstate) 1))
            (at end   (decrease (number-of-tools-in-state in-transitstate) 1))
            (at start (increase (number-of-tools-in-state-location in-transitstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location in-transitstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-in-transit) 1))
            ;; (at end   (decrease (number-of-tools-in-state-in-transit) 1))
        )
    )

    (:durative-action fxd-wopending
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t fxd-wopendingstate))
            (at end   (not (state ?t fxd-wopendingstate)))
            (at start (increase (number-of-tools-in-state fxd-wopendingstate) 1))
            (at end   (decrease (number-of-tools-in-state fxd-wopendingstate) 1))
            (at start (increase (number-of-tools-in-state-location fxd-wopendingstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location fxd-wopendingstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-fxd-wopending) 1))
            ;; (at end   (decrease (number-of-tools-in-state-fxd-wopending) 1))
        )
    )

    (:durative-action rite-rff
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rite-rffstate))
            (at end   (not (state ?t rite-rffstate)))
            (at start (increase (number-of-tools-in-state rite-rffstate) 1))
            (at end   (decrease (number-of-tools-in-state rite-rffstate) 1))
            (at start (increase (number-of-tools-in-state-location rite-rffstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rite-rffstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rite-rff) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rite-rff) 1))
        )
    )

    (:durative-action rong-used
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rong-usedstate))
            (at end   (not (state ?t rong-usedstate)))
            (at start (increase (number-of-tools-in-state rong-usedstate) 1))
            (at end   (decrease (number-of-tools-in-state rong-usedstate) 1))
            (at start (increase (number-of-tools-in-state-location rong-usedstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rong-usedstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rong-used) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rong-used) 1))
        )
    )

    (:durative-action fxd-underservice
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t fxd-underservicestate))
            (at end   (not (state ?t fxd-underservicestate)))
            (at start (increase (number-of-tools-in-state fxd-underservicestate) 1))
            (at end   (decrease (number-of-tools-in-state fxd-underservicestate) 1))
            (at start (increase (number-of-tools-in-state-location fxd-underservicestate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location fxd-underservicestate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-fxd-underservice) 1))
            ;; (at end   (decrease (number-of-tools-in-state-fxd-underservice) 1))
        )
    )

    (:durative-action onlocation-transittorig
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t onlocation-transittorigstate))
            (at end   (not (state ?t onlocation-transittorigstate)))
            (at start (increase (number-of-tools-in-state onlocation-transittorigstate) 1))
            (at end   (decrease (number-of-tools-in-state onlocation-transittorigstate) 1))
            (at start (increase (number-of-tools-in-state-location onlocation-transittorigstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location onlocation-transittorigstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-onlocation-transittorig) 1))
            ;; (at end   (decrease (number-of-tools-in-state-onlocation-transittorig) 1))
        )
    )

    (:durative-action rite-inprocess
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rite-inprocessstate))
            (at end   (not (state ?t rite-inprocessstate)))
            (at start (increase (number-of-tools-in-state rite-inprocessstate) 1))
            (at end   (decrease (number-of-tools-in-state rite-inprocessstate) 1))
            (at start (increase (number-of-tools-in-state-location rite-inprocessstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rite-inprocessstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rite-inprocess) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rite-inprocess) 1))
        )
    )

    (:durative-action transferred-repair
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t transferred-repairstate))
            (at end   (not (state ?t transferred-repairstate)))
            (at start (increase (number-of-tools-in-state transferred-repairstate) 1))
            (at end   (decrease (number-of-tools-in-state transferred-repairstate) 1))
            (at start (increase (number-of-tools-in-state-location transferred-repairstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location transferred-repairstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-transferred-repair) 1))
            ;; (at end   (decrease (number-of-tools-in-state-transferred-repair) 1))
        )
    )

    (:durative-action rong-repair
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t rong-repairstate))
            (at end   (not (state ?t rong-repairstate)))
            (at start (increase (number-of-tools-in-state rong-repairstate) 1))
            (at end   (decrease (number-of-tools-in-state rong-repairstate) 1))
            (at start (increase (number-of-tools-in-state-location rong-repairstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location rong-repairstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-rong-repair) 1))
            ;; (at end   (decrease (number-of-tools-in-state-rong-repair) 1))
        )
    )

    (:durative-action fxd-pendingapproval
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t fxd-pendingapprovalstate))
            (at end   (not (state ?t fxd-pendingapprovalstate)))
            (at start (increase (number-of-tools-in-state fxd-pendingapprovalstate) 1))
            (at end   (decrease (number-of-tools-in-state fxd-pendingapprovalstate) 1))
            (at start (increase (number-of-tools-in-state-location fxd-pendingapprovalstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location fxd-pendingapprovalstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-fxd-pendingapproval) 1))
            ;; (at end   (decrease (number-of-tools-in-state-fxd-pendingapproval) 1))
        )
    )

    (:durative-action transferred-loaned
        :parameters (?t - tool ?l - location)
        :duration (>= ?duration 0.49)
        :condition (and 
            (at start (at ?t ?l))
        )
        :effect (and 
            (at start (state ?t transferred-loanedstate))
            (at end   (not (state ?t transferred-loanedstate)))
            (at start (increase (number-of-tools-in-state transferred-loanedstate) 1))
            (at end   (decrease (number-of-tools-in-state transferred-loanedstate) 1))
            (at start (increase (number-of-tools-in-state-location transferred-loanedstate ?l) 1))
            (at end   (decrease (number-of-tools-in-state-location transferred-loanedstate ?l) 1))
            ;; (at start (increase (number-of-tools-in-state-transferred-loaned) 1))
            ;; (at end   (decrease (number-of-tools-in-state-transferred-loaned) 1))
        )
    )

)