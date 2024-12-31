;; Define principal data structures
(define-map participants 
  ((participant principal)) 
  ((amount uint)
   (join-time uint)
   (voting-power uint)))

;; Track total funds
(define-data-var total-pool uint u0)

;; Define milestones
(define-map milestones 
  ((milestone-id uint))
  ((description (string-ascii 256))
   (required-votes uint)
   (completed bool)))

;; Deposit funds
(define-public (deposit)
  (let ((amount (get-deposit-amount)))
    (if (> amount u0)
      (begin
        (try! (stx-transfer? amount tx-sender (contract-principal)))
        (map-set participants {participant: tx-sender}
                            {amount: amount,
                             join-time: block-height,
                             voting-power: amount})
        (ok true))
      (err u1))))

;; Propose milestone completion
(define-public (propose-milestone-completion (milestone-id uint))
  (let ((milestone (unwrap! (map-get? milestones {milestone-id: milestone-id}) (err u2))))
    (if (is-validator tx-sender)
      (begin
        (map-set milestones 
          {milestone-id: milestone-id}
          (merge milestone {completed: true}))
        (ok true))
      (err u3))))
