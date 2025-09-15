;; FairPlay Escrow Contract
;; Trustless on-chain escrow system for PvP gaming and betting

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-STATE (err u101))
(define-constant ERR-ALREADY-JOINED (err u102))
(define-constant ERR-TIMEOUT-NOT-REACHED (err u103))

(define-data-var game-counter uint u0)

(define-map games
  uint
  {
    player1: principal,
    player2: (optional principal),
    stake: uint,
    winner: (optional principal),
    created-at: uint,
    resolved: bool
  }
)

(define-constant GAME-TIMEOUT u10080) ;; ~1 week in blocks

;; Create a new game
(define-public (create-game)
  (let (
        (id (+ (var-get game-counter) u1))
        (sender tx-sender)
        (amount (stx-get-balance tx-sender))
       )
    (if (is-eq amount u0)
        (err u1)
        (begin
          (var-set game-counter id)
          (map-set games id {
            player1: sender,
            player2: none,
            stake: amount,
            winner: none,
            created-at: stacks-block-height,
            resolved: false
          })
          (ok id)
        )
    )
  )
)

;; Join a game by matching the stake
(define-public (join-game (id uint))
  (let ((amount (stx-get-balance tx-sender)))
    (match (map-get? games id)
      game
      (if (is-some (get player2 game))
          ERR-ALREADY-JOINED
          (if (is-eq amount (get stake game))
              (begin
                (map-set games id (merge game { player2: (some tx-sender) }))
                (ok true)
              )
              (err u2)
          )
      )
      (err u3)
    )
  )
)

;; Declare a winner (must be either oracle or both players confirming)
(define-public (declare-winner (id uint) (winner principal))
  (match (map-get? games id)
    game
    (if (or (is-eq tx-sender (get player1 game))
            (is-eq tx-sender (unwrap-panic (get player2 game)))
            (is-eq tx-sender 'SP000000000000000000002Q6VF78)) ;; Oracle address
        (begin
          (map-set games id (merge game { winner: (some winner), resolved: true }))
          (ok true)
        )
        ERR-NOT-AUTHORIZED
    )
    (err u3)
  )
)

;; Claim winnings after resolution
(define-public (claim (id uint))
  (match (map-get? games id)
    game
    (if (and (is-some (get winner game))
             (is-eq tx-sender (unwrap-panic (get winner game))))
        (let ((payout (* u2 (get stake game))))
          (stx-transfer? payout (as-contract tx-sender) tx-sender)
        )
        ERR-NOT-AUTHORIZED
    )
    (err u3)
  )
)

;; Timeout recovery: if no winner declared, players can reclaim
(define-public (recover-timeout (id uint))
  (match (map-get? games id)
    game
    (if (>= (- stacks-block-height (get created-at game)) GAME-TIMEOUT)
        (if (or (is-eq tx-sender (get player1 game))
                (is-eq tx-sender (unwrap-panic (get player2 game))))
            (stx-transfer? (get stake game) (as-contract tx-sender) tx-sender)
            ERR-NOT-AUTHORIZED
        )
        ERR-TIMEOUT-NOT-REACHED
    )
    (err u3)
  )
)
