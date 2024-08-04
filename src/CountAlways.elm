module CountAlways exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Json.Encode as Encode
import Review.Rule as Rule exposing (Rule)


{-| Reports... REPLACEME

    config =
        [ CountAlways.rule
        ]


## Fail

    a =
        "REPLACEME example to replace"


## Success

    a =
        "REPLACEME example to replace"


## When (not) to enable this rule

This rule is useful when REPLACEME.
This rule is not useful when REPLACEME.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template jfmengels/elm-review-metrics/example --rules CountAlways
```

-}
rule : Rule
rule =
    Rule.newProjectRuleSchema "CountAlways" initialProjectContext
        |> Rule.withModuleVisitor moduleVisitor
        |> Rule.withModuleContextUsingContextCreator
            { fromProjectToModule = fromProjectToModule
            , fromModuleToProject = fromModuleToProject
            , foldProjectContexts = foldProjectContexts
            }
        |> Rule.withDataExtractor dataExtractor
        |> Rule.fromProjectRuleSchema


type alias ProjectContext =
    { noArgs : Int
    , singleArg : Int
    , bothArgs : Int
    }


type alias ModuleContext =
    { noArgs : Int
    , singleArg : Int
    , bothArgs : Int
    }


moduleVisitor : Rule.ModuleRuleSchema schema ModuleContext -> Rule.ModuleRuleSchema { schema | hasAtLeastOneVisitor : () } ModuleContext
moduleVisitor schema =
    schema
        |> Rule.withExpressionEnterVisitor expressionVisitor


initialProjectContext : ProjectContext
initialProjectContext =
    { noArgs = 0
    , singleArg = 0
    , bothArgs = 0
    }


fromProjectToModule : Rule.ContextCreator ProjectContext ModuleContext
fromProjectToModule =
    Rule.initContextCreator
        (\_ ->
            { noArgs = 0
            , singleArg = 0
            , bothArgs = 0
            }
        )


fromModuleToProject : Rule.ContextCreator ModuleContext ProjectContext
fromModuleToProject =
    Rule.initContextCreator
        (\moduleContext ->
            { noArgs = moduleContext.noArgs
            , singleArg = moduleContext.singleArg
            , bothArgs = moduleContext.bothArgs
            }
        )


foldProjectContexts : ProjectContext -> ProjectContext -> ProjectContext
foldProjectContexts new previous =
    { noArgs = new.noArgs + previous.noArgs
    , singleArg = new.singleArg + previous.singleArg
    , bothArgs = new.bothArgs + previous.bothArgs
    }


expressionVisitor : Node Expression -> ModuleContext -> ( List (Rule.Error {}), ModuleContext )
expressionVisitor node context =
    case Node.value node of
        _ ->
            ( [], context )


dataExtractor : ProjectContext -> Encode.Value
dataExtractor context =
    Encode.object
        [ ( "noArgs", Encode.int context.noArgs )
        , ( "singleArg", Encode.int context.singleArg )
        , ( "bothArgs", Encode.int context.bothArgs )
        ]
