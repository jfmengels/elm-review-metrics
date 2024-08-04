module CountAlwaysTest exposing (all)

import CountAlways exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "CountAlways"
        [ test "should not report an error when REPLACEME" <|
            \() ->
                """module A exposing (..)
a = List.indexedMap always list
b = List.map (always 1) list
c = always 1 2
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectDataExtract """
{ "noArgs": 1
, "singleArg": 1
, "bothArgs": 1
}
"""
        ]
