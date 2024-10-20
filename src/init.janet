(import resp)

(defmacro make-command [name docs]
  ~(def ,name ,docs (fn [client & args]
                      (:send client (map string [;(string/split "-" (string ',name)) ;args])))))

(make-command aof "Downloads the AOF starting from pos and keeps the connection alive")
(make-command aofmd5 "Performs a checksum on a portion of the AOF")
(make-command aofshrink "Shrinks the AOF in the background")
(make-command auth "Authenticate to the server")
(make-command bounds "Get the combined bounds of all the objects in a key")
(make-command config-get "Get the value of a configuration parameter")
(make-command config-rewrite "Rewrite the configuration file with the in memory configuration")
(make-command config-set "Set a configuration parameter to the given value")
(make-command del "Delete an ID from a key")
(make-command delchan "Removes a channel")
(make-command delhook "Removes a webhook")
(make-command drop "Remove a key from the database")
(make-command eval "Evaluates a Lua script")
(make-command evalna "Evaluates a Lua script in a non-atomic fashion")
(make-command evalnasha "Evaluates, in a non-atomic fashion, a Lua script cached on the server by its SHA1 digest")
(make-command evalro "Evaluates a read-only Lua script")
(make-command evalrosha "Evaluates a read-only Lua script cached on the server by its SHA1 digest")
(make-command evalsha "Evaluates a Lua script cached on the server by its SHA1 digest")
(make-command exists "Checks to see if an ID exists")
(make-command expire "Set a timeout on an ID")
(make-command fexists "Checks to see if a field exists on an ID")
(make-command fget "Gets the value for the field of an ID")
(make-command flushdb "Removes all keys")
(make-command follow "Follows a leader host")
(make-command fset "Set the value for one or more fields of an ID")
(make-command gc "Forces a garbage collection")
(make-command get "Get the object of an ID")
(make-command healthz "Healthchecks on leader and follower")
(make-command hooks "Finds all hooks matching a pattern")
(make-command info "Gets information about the server")
(make-command intersects "Searches for IDs that intersect an area")
(make-command jdel "Delete a value from a JSON document")
(make-command jget "Get a value from a JSON document")
(make-command jset "Set a value in a JSON document")
(make-command keys "Finds all keys matching the given pattern")
(make-command nearby "Searches for IDs that are nearby a point")
(make-command output "Gets or sets the output format for the current connection") # @TODO add JSON decoding?
(make-command pdel "Removes all objects matching a pattern")
(make-command pdelchan "Removes all channels matching a pattern")
(make-command pdelhook "Removes all hooks matching a pattern")
(make-command persist "Remove the existing timeout on an ID")
(make-command ping "Ping the server")
(make-command psubscribe "Subscribes the client to the given patterns")
(make-command quit "Close the connection")
(make-command readonly "Turns on or off readonly mode")
(make-command rename "Rename a key to be stored under a different name")
(make-command renamex "Rename a key to be stored under a different name if it does not yet exist")
(make-command role "Gets information about the leader/follower status")
(make-command scan "Incrementally iterate through a key")
(make-command script-exists "Returns information about the existence of a script in the server cache")
(make-command script-flush "Flushes the server cache of Lua scripts")
(make-command script-load "Loads the compiled version of a script into the server cache")
(make-command search "Search for string values in a key")
(make-command server "Show server stats and details")
(make-command set "Sets the value of an ID")
(make-command setchan "Creates a pubsub channel which points to a geofenced search")
(make-command sethook "Creates a webhook which points to a geofenced search")
(make-command stats "Show stats for one or more keys")
(make-command subscribe "Subscribe to a geofence channel")
(make-command test "Performs spatial test")
(make-command timeout "Runs the following command with the timeout")
(make-command ttl "Get a timeout on an ID")
(make-command within "Searches for IDs that are within an area")

(defn make-client
  "Creates a new Tile38 client"
  [&opt host port pass]
  (default host "127.0.0.1")
  (default port 9851)
  (default pass nil)
  (def conn (net/connect host (string port) :stream))
  (if pass (:write conn (resp/encode ["auth" pass])))
  {:send (fn [self command] (:write conn (resp/encode command)) (first (resp/decode (:read conn 1024))))
   :close (fn [self] (net/close conn))
   :watch (fn [self ch stop-ch &opt timeout]
            (default timeout 0.5)
            (var events nil)
            (var stop false)
            (forever
              (if stop (break))
              (try
                (do
                  # could probably use ev/count here instead and close the
                  # stop channel from the inside, but then I can't
                  # reuse it for multiple watchers
                  (ev/with-deadline timeout (do
                                              (def select-res (ev/select stop-ch))
                                              (if (= (first select-res) :close)
                                                (set stop true)))))
                ([err]
                  (do
                    (if (not= err "deadline expired") (error err))
                    (try
                      (do
                        (set events (:read conn 1024 nil timeout))
                        (if (not (nil? events)) (do
                                                  (def events-decoded (resp/decode events))
                                                  (each event events-decoded (do
                                                                               (def select-res (ev/select [ch event]))
                                                                               (if (= (first select-res) :close) (do (set stop true) (break))))))))
                      ([e] (do
                             (if (not= e "timeout") (error e))))))))))})

(defn close
  "Closes the connection on the client"
  [client]
  (:close client))

(defn watch
  "Watches for events and passes them into the received channel. Stops when either of the two channels is closed."
  [client event-ch stop-ch &opt timeout]
  (default timeout 0.5)
  (:watch client event-ch stop-ch timeout))
