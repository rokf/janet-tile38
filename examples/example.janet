(import ../src :prefix "tile38/")

# some commands don't require authentication
(def client (tile38/make-client))
(pp (tile38/ping client))
(pp (tile38/ping client 500))
(pp (tile38/close client))

# the password can be sent as a command before those that require
# authentication
(with [c (tile38/make-client)]
  (pp (tile38/auth c "secret-password-123"))
  (pp (tile38/server c))
  (pp (tile38/info c)))

# or as the third argument to make-client
(with [c (tile38/make-client nil nil "secret-password-123")]
  (pp (tile38/set c :fleet :drone001 :point 10.55 -15.35))
  (pp (tile38/get c :fleet :drone001 :point)))

(def json-chan (ev/chan 10))
(def stop-chan (ev/chan))

(ev/spawn (with [c (tile38/make-client nil nil "secret-password-123")]
            (tile38/setchan c :warehouse :nearby :fleet :fence :point 33.462 -112.268 10000)
            (pp (tile38/subscribe c :warehouse))
            (tile38/watch c json-chan stop-chan)
            (pp "Closed")))

(ev/sleep 1)

(with [c (tile38/make-client nil nil "secret-password-123")]
  (pp (tile38/set c :fleet :bus1 :point 33.460 -112.260))
  (pp (tile38/set c :fleet :bus2 :point 33.461 -112.259)))

(ev/sleep 1)

(with [c (tile38/make-client nil nil "secret-password-123")]
  (pp (tile38/set c :fleet :bus3 :point 33.462 -112.265))
  (pp (tile38/set c :fleet :bus4 :point 33.463 -112.258)))

(ev/sleep 6)

(pp (ev/count json-chan))
(pp (ev/take json-chan))
(ev/chan-close stop-chan)
