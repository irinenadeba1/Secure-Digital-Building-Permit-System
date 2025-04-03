;; Property Verification Contract
;; Validates ownership and zoning compliance

(define-data-var admin principal tx-sender)

;; Map to store property details
(define-map properties
  { property-id: (string-ascii 32) }
  {
    owner: principal,
    zone-type: (string-ascii 20),
    verified: bool
  }
)

;; Function to register a property
(define-public (register-property (property-id (string-ascii 32)) (zone-type (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set properties { property-id: property-id }
                {
                  owner: tx-sender,
                  zone-type: zone-type,
                  verified: false
                }))
  )
)

;; Function to verify a property
(define-public (verify-property (property-id (string-ascii 32)))
  (let ((property (unwrap! (map-get? properties { property-id: property-id }) (err u101))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u100))
      (ok (map-set properties { property-id: property-id }
                  (merge property { verified: true })))
    )
  )
)

;; Function to check if a property is verified
(define-read-only (is-property-verified (property-id (string-ascii 32)))
  (default-to false (get verified (map-get? properties { property-id: property-id })))
)

;; Function to get property details
(define-read-only (get-property (property-id (string-ascii 32)))
  (map-get? properties { property-id: property-id })
)

;; Function to transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
