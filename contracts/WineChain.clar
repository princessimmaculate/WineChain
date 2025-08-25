;; WineChain - Wine Authenticity Verification System
;; Version: 1.0.0
;; Track wine authenticity from vineyard to cellar with sommelier validation

(define-map wines uint {
  vintner: principal,
  wine-vintage: (string-utf8 64),
  terroir-details: (string-utf8 256),
  harvest-date: uint,
  vineyard-location: (string-utf8 64),
  quality-verified: bool
})

(define-map vintner-bottles principal (list 100 uint))
(define-map wine-sommeliers principal bool)
(define-data-var bottle-id-tracker uint u0)

;; Error codes
(define-constant err-not-vintner (err u400))
(define-constant err-not-sommelier (err u401))
(define-constant err-wine-not-found (err u402))
(define-constant err-permission-denied (err u403))
(define-constant err-bottle-limit-reached (err u404))
(define-constant err-invalid-sommelier-address (err u405))
(define-constant err-invalid-wine-vintage (err u406))
(define-constant err-invalid-terroir (err u407))
(define-constant err-invalid-harvest-date (err u408))
(define-constant err-invalid-vineyard-name (err u409))
(define-constant err-invalid-bottle-id (err u410))

;; Contract supervisor for quality control
(define-constant contract-supervisor tx-sender)

;; Register wine sommelier
(define-public (register-wine-sommelier (sommelier principal))
  (begin
    ;; Check if sender is contract supervisor
    (asserts! (is-eq tx-sender contract-supervisor) err-permission-denied)
    
    ;; Validate sommelier principal
    (asserts! (not (is-eq sommelier 'SP000000000000000000002Q6VF78)) err-invalid-sommelier-address)
    
    ;; Add sommelier to registry
    (ok (map-set wine-sommeliers sommelier true))
  ))

;; Register wine bottle
(define-public (register-wine-bottle
  (wine-vintage (string-utf8 64))
  (terroir-details (string-utf8 256))
  (harvest-date uint)
  (vineyard-location (string-utf8 64)))
  (let
    ((bottle-id (var-get bottle-id-tracker))
     (vintner tx-sender)
     (current-bottles (default-to (list) (map-get? vintner-bottles vintner))))
    
    ;; Validate inputs
    (asserts! (> (len wine-vintage) u0) err-invalid-wine-vintage)
    (asserts! (> (len terroir-details) u0) err-invalid-terroir)
    (asserts! (> harvest-date u0) err-invalid-harvest-date)
    (asserts! (> (len vineyard-location) u0) err-invalid-vineyard-name)
    
    ;; Check bottle registration limit
    (asserts! (< (len current-bottles) u100) err-bottle-limit-reached)
    
    ;; Store wine information
    (map-set wines bottle-id {
      vintner: vintner,
      wine-vintage: wine-vintage,
      terroir-details: terroir-details,
      harvest-date: harvest-date,
      vineyard-location: vineyard-location,
      quality-verified: false
    })
    
    ;; Update vintner's bottle list
    (let
      ((updated-bottle-list (unwrap-panic (as-max-len? (concat (list bottle-id) current-bottles) u100))))
      (map-set vintner-bottles vintner updated-bottle-list)
    )
    
    ;; Increment bottle ID tracker
    (var-set bottle-id-tracker (+ bottle-id u1))
    
    (ok bottle-id)))

;; Verify wine quality
(define-public (verify-wine-quality (bottle-id uint))
  (begin
    ;; Validate bottle ID
    (asserts! (< bottle-id (var-get bottle-id-tracker)) err-invalid-bottle-id)
    
    (let
      ((wine (unwrap! (map-get? wines bottle-id) err-wine-not-found)))
      
      ;; Check if sender is wine sommelier
      (asserts! (default-to false (map-get? wine-sommeliers tx-sender)) err-not-sommelier)
      
      ;; Update wine quality verification status
      (ok (map-set wines bottle-id (merge wine {quality-verified: true})))
    )
  ))

;; Get wine details
(define-read-only (get-wine (bottle-id uint))
  (map-get? wines bottle-id))

;; Get vintner's bottles
(define-read-only (get-vintner-bottles (vintner principal))
  (default-to (list) (map-get? vintner-bottles vintner)))

;; Check wine sommelier status
(define-read-only (is-wine-sommelier (address principal))
  (default-to false (map-get? wine-sommeliers address)))

;; Get total bottles
(define-read-only (get-total-bottles)
  (var-get bottle-id-tracker))

;; Get contract stats
(define-read-only (get-contract-stats)
  {
    supervisor: contract-supervisor,
    total-bottles: (var-get bottle-id-tracker)
  })