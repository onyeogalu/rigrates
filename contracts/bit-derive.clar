;; Rigrates - Bitcoin Mining Difficulty Derivatives
;; A synthetic Bitcoin exposure instrument tracking mining difficulty

;; Contract Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_DIFFICULTY (err u103))
(define-constant ERR_ORACLE_NOT_FOUND (err u104))
(define-constant ERR_POSITION_NOT_FOUND (err u105))
(define-constant ERR_ALREADY_SETTLED (err u106))

;; Data Variables
(define-data-var current-difficulty uint u0)
(define-data-var last-update-height uint u0)
(define-data-var total-long-positions uint u0)
(define-data-var total-short-positions uint u0)
(define-data-var contract-paused bool false)

;; Data Maps
(define-map user-positions 
  principal 
  {
    long-amount: uint,
    short-amount: uint,
    entry-difficulty: uint,
    entry-height: uint,
    settled: bool
  }
)

(define-map difficulty-oracle
  uint ;; block height
  {
    difficulty: uint,
    timestamp: uint,
    oracle: principal
  }
)

(define-map authorized-oracles principal bool)

;; Read-only functions
(define-read-only (get-current-difficulty)
  (var-get current-difficulty)
)

(define-read-only (get-user-position (user principal))
  (map-get? user-positions user)
)

(define-read-only (get-difficulty-at-height (height uint))
  (map-get? difficulty-oracle height)
)

(define-read-only (get-total-positions)
  {
    long: (var-get total-long-positions),
    short: (var-get total-short-positions)
  }
)

(define-read-only (calculate-pnl (user principal))
  (let (
    (position (unwrap! (map-get? user-positions user) (err u0)))
    (current-diff (var-get current-difficulty))
    (entry-diff (get entry-difficulty position))
    (long-amt (get long-amount position))
    (short-amt (get short-amount position))
  )
    (if (> current-diff entry-diff)
      ;; Difficulty increased - longs profit, shorts lose
      (ok {
        long-pnl: (/ (* long-amt (- current-diff entry-diff)) entry-diff),
        short-pnl: (- (/ (* short-amt (- current-diff entry-diff)) entry-diff))
      })
      ;; Difficulty decreased - shorts profit, longs lose
      (ok {
        long-pnl: (- (/ (* long-amt (- entry-diff current-diff)) entry-diff)),
        short-pnl: (/ (* short-amt (- entry-diff current-diff)) entry-diff)
      })
    )
  )
)

;; Authorization functions
(define-public (add-oracle (oracle-addr principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set authorized-oracles oracle-addr true)
    (ok true)
  )
)

(define-public (remove-oracle (oracle-addr principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-delete authorized-oracles oracle-addr)
    (ok true)
  )
)

(define-read-only (is-authorized-oracle (oracle principal))
  (default-to false (map-get? authorized-oracles oracle))
)

;; Oracle functions
(define-public (update-difficulty (new-difficulty uint))
  (begin
    (asserts! (is-authorized-oracle tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (> new-difficulty u0) ERR_INVALID_DIFFICULTY)
    
    ;; Update difficulty data
    (var-set current-difficulty new-difficulty)
    (var-set last-update-height burn-block-height)
    
    ;; Store oracle data
    (map-set difficulty-oracle burn-block-height {
      difficulty: new-difficulty,
      timestamp: burn-block-height,
      oracle: tx-sender
    })
    
    (ok true)
  )
)

;; Position management
(define-public (open-long-position (amount uint))
  (let (
    (current-diff (var-get current-difficulty))
    (current-height burn-block-height)
    (existing-position (default-to 
      {long-amount: u0, short-amount: u0, entry-difficulty: u0, entry-height: u0, settled: false}
      (map-get? user-positions tx-sender)
    ))
  )
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> current-diff u0) ERR_INVALID_DIFFICULTY)
    
    ;; Update user position
    (map-set user-positions tx-sender {
      long-amount: (+ (get long-amount existing-position) amount),
      short-amount: (get short-amount existing-position),
      entry-difficulty: (if (is-eq (get long-amount existing-position) u0) 
                          current-diff 
                          (get entry-difficulty existing-position)),
      entry-height: (if (is-eq (get long-amount existing-position) u0) 
                     current-height 
                     (get entry-height existing-position)),
      settled: false
    })
    
    ;; Update total positions
    (var-set total-long-positions (+ (var-get total-long-positions) amount))
    
    (ok true)
  )
)

(define-public (open-short-position (amount uint))
  (let (
    (current-diff (var-get current-difficulty))
    (current-height burn-block-height)
    (existing-position (default-to 
      {long-amount: u0, short-amount: u0, entry-difficulty: u0, entry-height: u0, settled: false}
      (map-get? user-positions tx-sender)
    ))
  )
    (asserts! (not (var-get contract-paused)) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (> current-diff u0) ERR_INVALID_DIFFICULTY)
    
    ;; Update user position
    (map-set user-positions tx-sender {
      long-amount: (get long-amount existing-position),
      short-amount: (+ (get short-amount existing-position) amount),
      entry-difficulty: (if (is-eq (get short-amount existing-position) u0) 
                          current-diff 
                          (get entry-difficulty existing-position)),
      entry-height: (if (is-eq (get short-amount existing-position) u0) 
                     current-height 
                     (get entry-height existing-position)),
      settled: false
    })
    
    ;; Update total positions
    (var-set total-short-positions (+ (var-get total-short-positions) amount))
    
    (ok true)
  )
)

(define-public (close-position)
  (let (
    (position (unwrap! (map-get? user-positions tx-sender) ERR_POSITION_NOT_FOUND))
    (pnl-result (unwrap! (calculate-pnl tx-sender) ERR_POSITION_NOT_FOUND))
  )
    (asserts! (not (get settled position)) ERR_ALREADY_SETTLED)
    
    ;; Update total positions
    (var-set total-long-positions (- (var-get total-long-positions) (get long-amount position)))
    (var-set total-short-positions (- (var-get total-short-positions) (get short-amount position)))
    
    ;; Mark position as settled
    (map-set user-positions tx-sender 
      (merge position {settled: true})
    )
    
    (ok pnl-result)
  )
)

;; Emergency functions
(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused true)
    (ok true)
  )
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set contract-paused false)
    (ok true)
  )
)

;; Liquidation functions (simplified)
(define-public (liquidate-position (user principal))
  (let (
    (position (unwrap! (map-get? user-positions user) ERR_POSITION_NOT_FOUND))
    (pnl-result (unwrap! (calculate-pnl user) ERR_POSITION_NOT_FOUND))
  )
    ;; Simple liquidation logic - in production would need more sophisticated risk management
    (asserts! (is-authorized-oracle tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get settled position)) ERR_ALREADY_SETTLED)
    
    ;; Force close position if PnL is too negative (risk management)
    (map-set user-positions user 
      (merge position {settled: true})
    )
    
    (ok true)
  )
)

;; Initialize contract
(begin
  (map-set authorized-oracles CONTRACT_OWNER true)
  (var-set current-difficulty u1000000000000) ;; Initial difficulty placeholder
)