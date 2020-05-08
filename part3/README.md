Part 3
======

## Installation

```bash
elm init
```

(Answer `y` when prompted.)


cp Main.elm src

## Building

```bash
elm-live Main.elm -- --output=elm.js
```

## References

* [The Elm Architecture](http://guide.elm-lang.org/architecture/)
* [`onClick` documentation](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-Events#onClick)
* [record update syntax reference](http://elm-lang.org/docs/syntax#records) (e.g. `{ model | query = "foo" }`)
