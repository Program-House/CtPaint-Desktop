module Page.AllowanceExceeded
    exposing
        ( Msg
        , css
        , track
        , update
        , view
        )

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Data.Tracking as Tracking
import Html exposing (Html, p)
import Html.CssHelpers
import Html.Custom
import Html.Events exposing (onClick)
import Route


-- TYPES --


type Msg
    = RegisterClicked



-- UPDATE --


update : Msg -> Cmd Msg
update msg =
    case msg of
        RegisterClicked ->
            Route.goTo Route.Register



-- TRACKING --


track : Msg -> Maybe Tracking.Event
track msg =
    case msg of
        RegisterClicked ->
            Tracking.noProps "register click"



-- STYLES --


type Class
    = Text


css : Stylesheet
css =
    [ Css.class Text
        [ width (px 600) ]
    ]
        |> namespace allowanceExceededNamespace
        |> stylesheet


allowanceExceededNamespace : String
allowanceExceededNamespace =
    Html.Custom.makeNamespace "AllowanceExceeded"



-- VIEW --


{ class } =
    Html.CssHelpers.withNamespace allowanceExceededNamespace


view : Html Msg
view =
    [ Html.Custom.header
        { text = "allowance exceeded"
        , closability = Html.Custom.NotClosable
        }
    , Html.Custom.cardBody [] viewContent
    ]
        |> Html.Custom.cardSolitary []
        |> List.singleton
        |> Html.Custom.background []


viewContent : List (Html Msg)
viewContent =
    [ p
        [ class [ Text ] ]
        [ Html.text allowanceExceededMsg ]
    , Html.Custom.menuButton
        [ onClick RegisterClicked ]
        [ Html.text "register" ]
    ]


allowanceExceededMsg : String
allowanceExceededMsg =
    """
    Sorry. Without an account, you can only use CtPaint 4 times a month.
    You have reached your monthly limit. You can keep using CtPaint, but
    only if you register an account.
    """
