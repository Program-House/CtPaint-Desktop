module Tos
    exposing
        ( Section
        , css
        , tos
        , view
        )

import Chadtech.Colors as Ct
import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html exposing (Html, br, div, p)
import Html.CssHelpers
import Html.Custom


-- STYLES --


type Class
    = Container
    | Title
    | Content
    | SectionClass
    | Odd
    | ListItem


css : Stylesheet
css =
    [ (Css.class Container << List.append Html.Custom.indent)
        [ backgroundColor Ct.background2
        , overflow scroll
        , height (px 400)
        ]
    , Css.class Title
        []
    , Css.class Odd
        [ backgroundColor Ct.background3 ]
    , Css.class SectionClass
        [ padding (px 8) ]
    , Css.class ListItem
        [ marginLeft (px 11) ]
    ]
        |> namespace tosNamespace
        |> stylesheet


tosNamespace : String
tosNamespace =
    Html.Custom.makeNamespace "TermsOfService"



-- VIEW --


{ class, classList } =
    Html.CssHelpers.withNamespace tosNamespace


view : Html msg
view =
    div
        [ class [ Container ] ]
        children


children : List (Html msg)
children =
    List.indexedMap sectionView tos


sectionView : Int -> Section -> Html msg
sectionView index section =
    div
        [ classList
            [ ( SectionClass, True )
            , ( Odd, index % 2 == 1 )
            ]
        ]
        (sectionChildren section ++ listChildren section)


sectionChildren : Section -> List (Html msg)
sectionChildren { title, content } =
    [ p
        [ class [ Title ] ]
        [ Html.text title ]
    , br [] []
    , p
        [ class [ Content ] ]
        [ Html.text content ]
    ]


listChildren : Section -> List (Html msg)
listChildren { list } =
    if List.isEmpty list then
        []
    else
        list
            |> List.map listItemView
            |> List.intersperse (br [] [])
            |> (::) (br [] [])


listItemView : String -> Html msg
listItemView listItem =
    p
        [ class [ ListItem ] ]
        [ Html.text ("* " ++ listItem) ]


type alias Section =
    { title : String
    , content : String
    , list : List String
    }


tos : List Section
tos =
    [ { title = "Definitions"
      , content = definitionsContent
      , list = []
      }
    , { title = "Terms"
      , content = termsContent
      , list = []
      }
    , { title = "Disclaimer"
      , content = disclaimerContent
      , list = []
      }
    , { title = "Limitations"
      , content = limitationsContent
      , list = []
      }
    , { title = "Privacy"
      , content = privacyContent
      , list = privacyList
      }
    ]


definitionsContent : String
definitionsContent =
    "Chad \"Chadtech\" Stearns, CEO of Chadtech Corporation, an S Corp of New York State, herein will be referred to as \"Chadtech\"."


termsContent : String
termsContent =
    "By accessing the CtPaint website, you are agreeing to be bound by these terms and conditions of use, all applicable laws and regulations, and agree that you are responsible for compliance with those those laws and regulations. You agree to this regardless as to whether you affirmatively agree to the terms of service, such as when you do so on the account registration page. If you do not agree with any of these terms, you are prohibited from using this site. The terms of service may change at any time, and in the event of a change, the change will be listed on the CtPaint website, and a notice will be sent to all registered CtPaint users."


disclaimerContent : String
disclaimerContent =
    "The material on this website are provided \"as is\". Chadtech makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties, including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights. Further, Chadtech does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its Internet web site or otherwise relating to such materials or on any sites linked to this site."


limitationsContent : String
limitationsContent =
    "In no event shall Chadtech or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption), arising out of the use or inability to use the materials on CtPaint, even if Chadtech has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you."


privacyContent : String
privacyContent =
    "User privacy is important to Chadtech. The privacy policy below describes how Chadtech handles private user data and identifying information."


privacyList : List String
privacyList =
    [ "CtPaint is developed using Amazon Web Services. All authentication is done using Amazon Web Services, and the best practices for using it. All user data is stored at Amazon through Amazon Web Services"
    , "Chadtech does not store your password and does not know what it is. Chadtech cannot access your password from your user data on the Amazon Web Services servers. During log in, passwords are cleared from memory immediately after the user attempts to log in."

    -- Commenting this out until local storage is a real feature
    --, "If you opt into local storage, then your files will be stored locally on your computer, and could therefore be possibly accessed by other users on the same computer if they searched your computer browsers local memory without your permission, but not by any feature of CtPaint. If you opt into local storage a notice of this will be shown."
    , "Chadtech will never give out identifying or personal information without the consent of the identified users, unless compelled to by law."
    , "Chadtech may look at your email address and may email you. The registration page of CtPaint asks if you would like to sometimes receive emails. If you choose not to, you will not receive emails about non-urgent things like updates or new feautres to CtPaint, but you may still receive emails about changes to the terms of service or in regard to other important matters."
    , "Chadtech may look at user data in an anonymized and aggregated way. Anonymizing user data means removing information that could be used to discover the identity of the user, such as emails, profile bios, usernames, user ids, and image data."
    , "Chadtech will never look at your private user data without your permission. Private user data in this context, means data only the user could access through the normal operation of CtPaint. Private images are an example."
    , "All drawings on CtPaint, except private drawings, which are only accessible to the silver subscription tier, are publicly accessible. This means that anyone with the corresponding url could access it."
    ]
