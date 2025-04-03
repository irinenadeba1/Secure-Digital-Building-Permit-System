;; Contractor Licensing Contract
;; Confirms qualifications of builders

(define-data-var admin principal tx-sender)

;; Map to store contractor licenses
(define-map contractor-licenses
  { contractor-id: principal }
  {
    license-number: (string-ascii 20),
    specialization: (string-ascii 30),
    expiration-block: uint,
    is-active: bool
  }
)

;; Function to register a contractor
(define-public (register-contractor
                (license-number (string-ascii 20))
                (specialization (string-ascii 30))
                (validity-period uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set contractor-licenses
                { contractor-id: tx-sender }
                {
                  license-number: license-number,
                  specialization: specialization,
                  expiration-block: (+ block-height validity-period),
                  is-active: true
                }))
  )
)

;; Function to check if a contractor license is valid
(define-read-only (is-license-valid (contractor-id principal))
  (let ((license (map-get? contractor-licenses { contractor-id: contractor-id })))
    (and
      (is-some license)
      (get is-active (default-to
                      {
                        license-number: "",
                        specialization: "",
                        expiration-block: u0,
                        is-active: false
                      }
                      license))
      (< block-height (get expiration-block (default-to
                                            {
                                              license-number: "",
                                              specialization: "",
                                              expiration-block: u0,
                                              is-active: false
                                            }
                                            license)))
    )
  )
)

;; Function to revoke a contractor license
(define-public (revoke-license (contractor-id principal))
  (let ((license (unwrap! (map-get? contractor-licenses { contractor-id: contractor-id }) (err u101))))
    (begin
      (asserts! (is-eq tx-sender (var-get admin)) (err u100))
      (ok (map-set contractor-licenses
                  { contractor-id: contractor-id }
                  (merge license { is-active: false })))
    )
  )
)

;; Function to get contractor license details
(define-read-only (get-contractor-license (contractor-id principal))
  (map-get? contractor-licenses { contractor-id: contractor-id })
)

;; Function to transfer admin rights
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
