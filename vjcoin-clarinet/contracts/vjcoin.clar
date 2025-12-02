;; vjcoin - a simple fungible token implementation
;;
;; This contract defines a basic fungible token called VJCOIN.
;; It tracks balances in a map and allows the owner to mint new
;; tokens, while any holder can transfer or burn their own tokens.

(define-fungible-token vjcoin)

;; -------------------------------------------------------------
;; constants
;; -------------------------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))

;; -------------------------------------------------------------
;; data vars
;; -------------------------------------------------------------

;; The account that is allowed to mint new tokens.
(define-data-var token-owner principal tx-sender)

;; Total supply of all minted tokens, minus burned tokens.
(define-data-var total-supply uint u0)

;; -------------------------------------------------------------
;; data maps
;; -------------------------------------------------------------

;; Per-principal token balances.
(define-map balances { owner: principal } { balance: uint })

;; -------------------------------------------------------------
;; internal helpers
;; -------------------------------------------------------------

(define-private (is-owner (sender principal))
  (is-eq sender (var-get token-owner)))

(define-private (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { owner: who }))))

;; -------------------------------------------------------------
;; public functions
;; -------------------------------------------------------------

;; Transfer tokens from tx-sender to a recipient.
(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (let (
          (sender tx-sender)
          (sender-balance (get-balance-internal sender))
         )
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (let (
            (recipient-balance (get-balance-internal recipient))
           )
        (map-set balances { owner: sender } { balance: (- sender-balance amount) })
        (map-set balances { owner: recipient } { balance: (+ recipient-balance amount) })
        (ok true)))))

;; Mint new tokens to a recipient. Only the token-owner may call this.
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (is-owner tx-sender) ERR_UNAUTHORIZED)
    (let (
          (current-supply (var-get total-supply))
          (recipient-balance (get-balance-internal recipient))
         )
      (var-set total-supply (+ current-supply amount))
      (map-set balances { owner: recipient } { balance: (+ recipient-balance amount) })
      (ok true))))

;; Burn tokens from the caller's balance, reducing total supply.
(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (let (
          (sender tx-sender)
          (sender-balance (get-balance-internal sender))
          (current-supply (var-get total-supply))
         )
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (map-set balances { owner: sender } { balance: (- sender-balance amount) })
      (var-set total-supply (- current-supply amount))
      (ok true))))

;; -------------------------------------------------------------
;; read-only functions
;; -------------------------------------------------------------

(define-read-only (get-balance (who principal))
  (get-balance-internal who))

(define-read-only (get-total-supply)
  (var-get total-supply))

(define-read-only (get-name)
  "VJ Coin")

(define-read-only (get-symbol)
  "VJCOIN")

(define-read-only (get-decimals)
  u6)

