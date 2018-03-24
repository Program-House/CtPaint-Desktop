module Page.ForgotPassword
    exposing
        ( Model
        , Msg
        , css
        , failed
        , init
        , succeeded
        , update
        , view
        )

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html exposing (Attribute, Html, a, div, form, input, p)
import Html.Attributes as Attr
import Html.CssHelpers
import Html.Custom
import Html.Events exposing (onClick, onInput, onSubmit)
import Ports exposing (JsMsg(ForgotPassword))
import Tuple.Infix exposing ((&))
import Util


-- TYPES --


type Model
    = Ready ReadyModel
    | Sending String
    | Success String
    | Fail String


type alias ReadyModel =
    { email : String
    , problem : Maybe Problem
    }


type Problem
    = Other String
    | EmailIsntValid


type Msg
    = EmailUpdated String
    | Submitted
    | SubmitClicked
    | Succeeded
    | Failed String


succeeded : Msg
succeeded =
    Succeeded


failed : String -> Msg
failed =
    Failed



-- INIT --


init : Model
init =
    { email = ""
    , problem = Nothing
    }
        |> Ready



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailUpdated str ->
            ifReady (updateEmail str) model

        Submitted ->
            attemptSubmit model

        SubmitClicked ->
            attemptSubmit model

        Succeeded ->
            case model of
                Sending email ->
                    Success email & Cmd.none

                _ ->
                    model & Cmd.none

        Failed err ->
            case model of
                Sending _ ->
                    Fail err & Cmd.none

                _ ->
                    model & Cmd.none


ifReady : (ReadyModel -> ( ReadyModel, Cmd Msg )) -> Model -> ( Model, Cmd Msg )
ifReady readyFunc model =
    case model of
        Ready readyModel ->
            readyFunc readyModel
                |> Tuple.mapFirst Ready

        _ ->
            model & Cmd.none


updateEmail : String -> ReadyModel -> ( ReadyModel, Cmd Msg )
updateEmail str readyModel =
    { readyModel
        | email = str
    }
        & Cmd.none


attemptSubmit : Model -> ( Model, Cmd Msg )
attemptSubmit model =
    case model of
        Ready readyModel ->
            readyModel
                |> setProblem
                |> submitIfNoProblem

        _ ->
            model & Cmd.none


submitIfNoProblem : ReadyModel -> ( Model, Cmd Msg )
submitIfNoProblem readyModel =
    case readyModel.problem of
        Just _ ->
            Ready readyModel & Cmd.none

        Nothing ->
            ( Sending readyModel.email
            , submit readyModel.email
            )


submit : String -> Cmd Msg
submit =
    ForgotPassword >> Ports.send



-- VALIDATE --


setProblem : ReadyModel -> ReadyModel
setProblem readyModel =
    { readyModel
        | problem = getProblem readyModel
    }


getProblem : ReadyModel -> Maybe Problem
getProblem readyModel =
    [ isEmailValid readyModel.email ]
        |> Util.firstJust


isEmailValid : String -> Maybe Problem
isEmailValid email =
    if Util.isValidEmail email then
        Nothing
    else
        Just EmailIsntValid



-- STYLES --


type Class
    = Text
    | Long
    | SendingText


css : Stylesheet
css =
    [ Css.class Text
        [ marginRight (px 8) ]
    , Css.class Long
        [ width (px 300) ]
    , Css.class SendingText
        [ marginBottom (px 8) ]
    ]
        |> namespace forgotPasswordNamespace
        |> stylesheet


forgotPasswordNamespace : String
forgotPasswordNamespace =
    Html.Custom.makeNamespace "ForgotPassword"



-- VIEW --


{ class } =
    Html.CssHelpers.withNamespace forgotPasswordNamespace


view : Model -> Html Msg
view model =
    [ Html.Custom.header
        { text = "forgot password"
        , closability = Html.Custom.NotClosable
        }
    , Html.Custom.cardBody []
        [ body model ]
    ]
        |> Html.Custom.cardSolitary []
        |> List.singleton
        |> Html.Custom.background []


body : Model -> Html Msg
body model =
    case model of
        Ready readyModel ->
            readyBody readyModel

        Sending _ ->
            sendingBody

        Success email ->
            successBody email

        Fail err ->
            failView err


failView : String -> Html Msg
failView err =
    p
        []
        [ Html.text ("ERROR! " ++ err) ]


successBody : String -> Html Msg
successBody email =
    p
        []
        [ Html.text ("Email!!!" ++ email) ]


readyBody : ReadyModel -> Html Msg
readyBody { email, problem } =
    form
        [ onSubmit Submitted ]
        [ Html.Custom.field []
            [ p
                [ class [ Text ] ]
                [ Html.text "email" ]
            , input
                [ class [ Long ]
                , Attr.value email
                , Attr.spellcheck False
                , onInput EmailUpdated
                ]
                []
            ]
        , Util.viewMaybe problem errorView
        , Html.Custom.menuButton
            [ onClick SubmitClicked ]
            [ Html.text "reset password" ]
        ]


sendingBody : Html Msg
sendingBody =
    div
        []
        [ p
            [ class [ SendingText ] ]
            [ Html.text "working.." ]
        , Html.Custom.spinner
        ]


errorView : Problem -> Html Msg
errorView =
    errorMsg >> Html.Custom.error []


errorMsg : Problem -> String
errorMsg problem =
    case problem of
        Other err ->
            err

        EmailIsntValid ->
            "Please enter a valid email address"
