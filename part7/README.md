Part 7
======

## Installation

```bash
elm init
```

(Answer `y` when prompted.)

cp Main.elm src
cp ../Auth.elm src

## Building

elm install elm/json
elm install NoRedInk/elm-json-decode-pipeline

```bash
elm-live Main.elm -- --output=main.js
```

## References

* [Running Effects](http://guide.elm-lang.org/architecture/effects/)
* [HTTP Error documentation](http://package.elm-lang.org/packages/evancz/elm-http/3.0.0/Http#Error)
* [Modules syntax reference](http://elm-lang.org/docs/syntax#modules)
