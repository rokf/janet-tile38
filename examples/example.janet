(import ../src :prefix "tile38/")

(def client (tile38/make-client))

(pp (tile38/ping client))

(with [c (tile38/make-client)]
  (pp (tile38/ping c 500))
  (pp (tile38/server c)))
