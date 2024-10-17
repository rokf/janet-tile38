(use judge)

(import ../src :prefix "tile38/")

(test-macro (tile38/make-command example "This is an example")
            (def example "This is an example" (fn [client & args] (:send client (map string [(splice (string/split "-" (string (quote example)))) (splice args)])))))
