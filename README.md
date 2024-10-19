# janet-tile38

A Janet client library for interfacing with Tile38.

## Installation

The library can be installed with `jpm` using `jpm install https://github.com/rokf/janet-tile38`
or by adding the following line into your project's dependency tuple:

```janet
{ :url "https://github.com/rokf/janet-tile38" :tag "main" }
```

## API

After the library is installed you should be able to import its `tile38`
module with `(import tile38)`.

### `tile38/make-client`

The `make-client` function takes three optional parameters:
- `host` (string), defaults to `127.0.0.1`
- `port` (number), defaults to `9851`
- `pass` (string), the password for authentication (if required), defaults to `nil`

It creates a new Tile38 client that wraps its RESP API. The client can be
used with Janet's `with`, because it implements a `:close` method.

```janet
(def client (tile38/make-client "localhost" 9852 "my-secret-123"))
```

### `tile38/{command}`

Functions for Tile38's commands are generated using a macro because they all
follow the same pattern. See [Commands](https://tile38.com/commands/#) for
details. See tests and examples for some practical usage examples. Generally
they're following the pattern below:

```
(tile38/{command} client & args)
```

Some commands don't take any arguments. In those cases you'd only have to pass
in the client.

### `tile38/close`

Closes the underlying connection stream.

```janet
(tile38/close client)
```

### `tile38/watch`

Waits for events (notifications) to appear in subscribed channels, decodes them
and pushes them into an event channel, which you have to pass as an argument
(`event-ch`). Exits cleanly if the `stop-ch` channel is closed using something
like `(ev/chan-close stop-ch)` from the standard library. The interval for
`stop-ch` state checks and reading from the client's internal Tile38 connection
can be configured using the optional `timeout` parameter, which defaults to
`0.5`, meaning half a second. By default it will wait for half a second each
loop iteration for the `stop-ch` channel to get closed and then it will try
to read from the connection for half a second, before going back to the `stop-ch`
check.

```janet
(tile38/watch client event-ch stop-ch &opt timeout)
```

## Examples

Usage examples can be found in the `examples` folder. The folder also contains
a Docker Compose specification that spins up a Tile38 server instance, which
has the configuration required by the examples.

## Tests

Unit tests can be found in the `test` folder. They require `judge` to be
installed on your machine. You can install `judge` with:

```sh
jpm install https://github.com/ianthehenry/judge
```

## License

MIT - see the `LICENSE` file for details.
