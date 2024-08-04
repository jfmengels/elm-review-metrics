# elm-review-metrics

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.

## Provided rules

- [`CountAlways`](https://package.elm-lang.org/packages/jfmengels/elm-review-metrics/1.0.0/CountAlways) - Reports REPLACEME.

## Configuration

```elm
module ReviewConfig exposing (config)

import CountAlways
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ CountAlways.rule
    ]
```

## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template jfmengels/elm-review-metrics/example
```
