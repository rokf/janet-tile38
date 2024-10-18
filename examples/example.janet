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
