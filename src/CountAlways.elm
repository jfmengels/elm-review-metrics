module CountAlways exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression exposing (Expression(..))
import Elm.Syntax.Node as Node exposing (Node(..))
import Elm.Syntax.Range exposing (Range)
import Json.Encode as Encode
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
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
    { lookupTable : ModuleNameLookupTable
    , rangesToIgnore : List Range
    , noArgs : Int
    , singleArg : Int
    , bothArgs : Int
    }


moduleVisitor : Rule.ModuleRuleSchema schema ModuleContext -> Rule.ModuleRuleSchema { schema | hasAtLeastOneVisitor : () } ModuleContext
moduleVisitor schema =
    schema
        |> Rule.withExpressionEnterVisitor (\expr ctx -> ( [], expressionVisitor expr ctx ))


initialProjectContext : ProjectContext
initialProjectContext =
    { noArgs = 0
    , singleArg = 0
    , bothArgs = 0
    }


fromProjectToModule : Rule.ContextCreator ProjectContext ModuleContext
fromProjectToModule =
    Rule.initContextCreator
        (\lookupTable _ ->
            { lookupTable = lookupTable
            , rangesToIgnore = []
            , noArgs = 0
            , singleArg = 0
            , bothArgs = 0
            }
        )
        |> Rule.withModuleNameLookupTable


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


expressionVisitor : Node Expression -> ModuleContext -> ModuleContext
expressionVisitor node context =
    case Node.value node of
        FunctionOrValue _ "always" ->
            if not (List.member (Node.range node) context.rangesToIgnore) && isFromBasics context.lookupTable node then
                { context | noArgs = context.noArgs + 1 }

            else
                context

        Application (((Node alwaysRange (FunctionOrValue _ "always")) as alwaysNode) :: _ :: restOfArgs) ->
            if isFromBasics context.lookupTable alwaysNode then
                if List.isEmpty restOfArgs then
                    { context
                        | rangesToIgnore = alwaysRange :: context.rangesToIgnore
                        , singleArg = context.singleArg + 1
                    }

                else
                    { context
                        | rangesToIgnore = alwaysRange :: context.rangesToIgnore
                        , bothArgs = context.bothArgs + 1
                    }

            else
                context

        _ ->
            context


isFromBasics : ModuleNameLookupTable -> Node a -> Bool
isFromBasics lookupTable node =
    ModuleNameLookupTable.moduleNameFor lookupTable node == Just [ "Basics" ]


dataExtractor : ProjectContext -> Encode.Value
dataExtractor context =
    Encode.object
        [ ( "noArgs", Encode.int context.noArgs )
        , ( "singleArg", Encode.int context.singleArg )
        , ( "bothArgs", Encode.int context.bothArgs )
        ]
