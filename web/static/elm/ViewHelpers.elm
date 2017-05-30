module ViewHelpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Messages exposing (Msg(..))
import Routing exposing (routingItem, urlFor)
import Html.Events exposing (onInput)
import Json.Decode as JD
import Models exposing (Model)
import Routing exposing (Route)


navigationOnClick : Msg -> Attribute Msg
navigationOnClick msg =
    Html.Events.onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (JD.succeed msg)


navContainer : Model -> Html Msg
navContainer model =
    nav [ class "pure-menu" ]
        [ ul [ class "pure-menu-list" ]
            (List.map (navItem model) (routingItem model.url.src_url))
        ]


fixedHeader : Model -> String -> (String -> List ( String, String, Route, String )) -> Html Msg
fixedHeader model siteTitle routingItem =
    div [ class "header" ]
        [ div [ class "home-menu pure-menu pure-menu-horizontal pure-menu-fixed" ]
            [ linkItem "/" siteTitle "pure-menu-heading"
            , ul
                [ class "pure-menu-list" ]
                (List.map (navItem model) (routingItem model.url.src_url))
            ]
        ]


menuHeading : String -> String -> Html Msg
menuHeading slug textToShow =
    linkItem slug textToShow "pure-menu-heading"


linkItem : String -> String -> String -> Html Msg
linkItem slug textToShow className =
    a
        [ href slug
        , navigationOnClick (NewUrl slug)
        , class className
        ]
        [ text textToShow ]


menuLinkItem : String -> String -> String -> Html Msg
menuLinkItem slug textToShow className =
    a
        [ href slug
        , navigationOnClick (ToggleSideMenu)
        , class className
        ]
        [ span [] []
        , text textToShow
        ]


navItem : Model -> ( String, String, Route, String ) -> Html Msg
navItem model ( title, iconClass, route, slug ) =
    let
        isCurrentLocation =
            model.route == route

        ( onClickCmd, newClass ) =
            case ( isCurrentLocation, route ) of
                ( False, route ) ->
                    ( route |> (urlFor model.url.src_url) |> NewUrl
                    , "pure-menu-item"
                    )

                _ ->
                    ( NoOp
                    , "pure-menu-item pure-menu-selected"
                    )
    in
        li [ class newClass ]
            [ a
                [ href slug
                , navigationOnClick onClickCmd
                , class "pure-menu-link"
                ]
                [ i [ class iconClass ] []
                , text title
                ]
            ]


socialLink : String -> String -> Html Msg
socialLink slug iconClass =
    li [ class "pure-menu-item" ]
        [ externalLinkItem slug "social-link" iconClass ""
        ]


contactLink : String -> String -> String -> Html Msg
contactLink slug iconClass textToShow =
    li [ class "pure-menu-item" ]
        [ externalLinkItem slug "pure-menu-link" iconClass textToShow
        ]


externalLinkItem : String -> String -> String -> String -> Html Msg
externalLinkItem slug linkClass iconClass textToShow =
    a [ class linkClass, href slug ]
        [ i [ class iconClass ] [ text textToShow ] ]
