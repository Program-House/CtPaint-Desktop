module Html.Custom
    exposing
        ( Closability(..)
        , cannotSelect
        , card
        , cardBody
        , cardSolitary
        , css
        , error
        , field
        , header
        , indent
        , makeNamespace
        , menuButton
        , outdent
        , spinner
        , toolButton
        )

import Chadtech.Colors exposing (..)
import Css exposing (..)
import Css.Elements exposing (a, body, canvas, form, p)
import Css.Namespace
import Html exposing (Attribute, Html)
import Html.Attributes
import Html.CssHelpers
import Html.Events exposing (onMouseDown)
import MouseEvents exposing (MouseEvent, Position)
import Tuple.Infix exposing ((:=))


-- STYLES --


type Class
    = Field
    | Card
    | Solitary
    | Submit
    | Body
    | Header
    | Selected
    | Null
    | Error
    | SpinnerContainer
    | ToolButton
    | Button


css : Stylesheet
css =
    [ body
        [ backgroundColor backgroundx2
        , margin zero
        , padding zero
        ]
    , canvas
        [ property "image-rendering" "pixelated" ]
    , cardStyle
    , p <|
        List.append
            basicFont
            [ margin zero
            , padding zero
            ]
    , headerStyle
    , input
    , aStyle
    , submit
    , fieldStyle
    , form
        [ margin (px 0) ]
    , (Css.class ToolButton << List.append outdent)
        [ width (px 20)
        , height (px 20)
        , fontFamilies [ "icons" ]
        , fontSize (em 1)
        , textAlign center
        , padding (px 0)
        , lineHeight (px 20)
        , active indent
        , withClass Selected indent
        ]
    , spinnerContainer
    , Css.class Error
        [ backgroundColor lowWarning
        , padding (px 8)
        ]
    ]
        |> Css.Namespace.namespace appNamespace
        |> Css.stylesheet


appNamespace : String
appNamespace =
    "Desktop"


makeNamespace : String -> String
makeNamespace thisNamespace =
    appNamespace ++ thisNamespace


spinnerContainer : Snippet
spinnerContainer =
    [ position relative
    , backgroundColor backgroundx2
    , height (px 16)
    , overflow hidden
    , width (px 200)
    , margin auto
    ]
        |> List.append indent
        |> Css.class SpinnerContainer


fieldStyle : Snippet
fieldStyle =
    [ marginBottom (px 8)
    , children
        [ p
            [ display inlineBlock
            , textAlign left
            ]
        ]
    ]
        |> Css.class Field


submit : Snippet
submit =
    [ margin auto
    , display table
    , marginTop (px 8)
    ]
        |> Css.class Submit


input : Snippet
input =
    [ backgroundColor backgroundx2
    , outline none
    , fontSize (em 2)
    , fontFamilies [ "hfnss" ]
    , color point
    , property "-webkit-font-smoothing" "none"
    , margin (px 0)
    , padding (px 0)
    ]
        |> List.append indent
        |> Css.Elements.input


headerStyle : Snippet
headerStyle =
    [ backgroundColor point
    , height (px 25)
    , width (calc (pct 100) minus (px 8))
    , position absolute
    , padding (px 2)
    , margin (px 2)
    , lineHeight (px 25)
    , paddingLeft (px 2)
    , children
        [ p
            [ color ignorable3
            , cursor default
            , margin (px 0)
            , display inlineBlock
            ]
        , a
            [ height (px 21)
            , width (px 21)
            , lineHeight (px 21)
            , padding (px 0)
            , float right
            , textAlign center
            ]
        ]
    ]
        |> Css.class Header


cardStyle : Snippet
cardStyle =
    [ backgroundColor ignorable2
    , borderTop3 (px 2) solid ignorable1
    , borderLeft3 (px 2) solid ignorable1
    , borderRight3 (px 2) solid ignorable3
    , borderBottom3 (px 2) solid ignorable3
    , children
        [ Css.class Body
            [ marginTop (px 31)
            , padding (px 8)
            , children
                []
            ]
        ]
    , textAlign left
    , Css.withClass Solitary
        [ position absolute
        , top (pct 50)
        , left (pct 50)
        , transform (translate2 (pct -50) (pct -50))
        ]
    ]
        |> Css.class Card


aStyle : Snippet
aStyle =
    let
        mixins =
            [ outdent
            , [ active indent ]
            , basicFont
            , cannotSelect
            ]
                |> List.concat
    in
    [ padding zero
    , textDecoration none
    , backgroundColor ignorable2
    , display inlineBlock
    , padding4 (px 4) (px 8) (px 4) (px 8)
    , cursor pointer
    , hover [ color pointier ]
    , withClass Selected indent
    , withClass Null
        [ backgroundColor ignorable1
        , hover [ color point ]
        , active outdent
        ]
    ]
        |> List.append mixins
        |> a


cannotSelect : List Style
cannotSelect =
    [ "-webkit-user-select" := "none"
    , "-moz-user-select" := "none"
    , "-ms-user-select" := "none"
    , "user-select" := "none"
    ]
        |> List.map (uncurry property)


indent : List Style
indent =
    [ borderTop3 (px 2) solid ignorable3
    , borderLeft3 (px 2) solid ignorable3
    , borderRight3 (px 2) solid ignorable1
    , borderBottom3 (px 2) solid ignorable1
    ]


outdent : List Style
outdent =
    [ borderTop3 (px 2) solid ignorable1
    , borderLeft3 (px 2) solid ignorable1
    , borderRight3 (px 2) solid ignorable3
    , borderBottom3 (px 2) solid ignorable3
    ]


basicFont : List Style
basicFont =
    [ fontFamilies [ "hfnss" ]
    , color point
    , property "-webkit-font-smoothing" "none"
    , fontSize (px 32)
    ]



-- VIEW --


{ classList, class } =
    Html.CssHelpers.withNamespace appNamespace


menuButton : List (Attribute msg) -> List (Html msg) -> Html msg
menuButton attrs =
    Html.a (class [ Submit ] :: attrs)


field : List (Attribute msg) -> List (Html msg) -> Html msg
field attrs =
    Html.div (class [ Field ] :: attrs)


type alias ToolButtonState msg =
    { icon : String
    , selected : Bool
    , attrs : List (Html.Attribute msg)
    }


toolButton : ToolButtonState msg -> Html msg
toolButton state =
    let
        attrs =
            [ classList
                [ ToolButton := True
                , Selected := state.selected
                ]
            ]
                ++ state.attrs
    in
    Html.a attrs [ Html.text state.icon ]


card : List (Attribute msg) -> List (Html msg) -> Html msg
card attrs =
    Html.div (class [ Card ] :: attrs)


cardSolitary : List (Attribute msg) -> List (Html msg) -> Html msg
cardSolitary attrs =
    Html.div (class [ Card, Solitary ] :: attrs)


cardBody : List (Attribute msg) -> List (Html msg) -> Html msg
cardBody attrs =
    Html.div (class [ Body ] :: attrs)


type alias HeaderState msg =
    { text : String
    , closability : Closability msg
    }


type Closability msg
    = Closable (CloseState msg)
    | NotClosable


type alias CloseState msg =
    { headerMouseDown : MouseEvent -> msg
    , xClick : msg
    }


header : HeaderState msg -> Html msg
header { text, closability } =
    case closability of
        Closable { headerMouseDown, xClick } ->
            Html.div
                [ class [ Header ]
                , MouseEvents.onMouseDown headerMouseDown
                ]
                [ Html.p [] [ Html.text text ]
                , Html.a [ onMouseDown xClick ] [ Html.text "x" ]
                ]

        NotClosable ->
            Html.div
                [ class [ Header ] ]
                [ Html.p [] [ Html.text text ] ]


spinner : Html msg
spinner =
    Html.div
        [ class [ SpinnerContainer ] ]
        [ Html.div
            [ Html.Attributes.class "spinner" ]
            []
        ]


error : String -> Html msg
error errMsg =
    Html.div
        [ class [ Error ] ]
        [ Html.p
            []
            [ Html.text errMsg ]
        ]
