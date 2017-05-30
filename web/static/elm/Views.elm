module Views exposing (..)

import Html exposing (Html, span, a, div, ul, li, text, nav, header)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Dict exposing (Dict)
import Array exposing (Array)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Markdown
import Routing exposing (Route(..), routingItem, tabsTitles, routingItemNormalHeader)
import Views.Home exposing (homeView)
import Views.Login exposing (loginView)
import Views.Chat exposing (chatView)
import ViewHelpers exposing (menuHeading, navItem, fixedHeader, menuLinkItem)
import Routing exposing (routingItem)


view : Model -> Html Msg
view model =
    let
        contentView =
            case model.route of
                HomeRoute ->
                    homeView model

                LoginRoute ->
                    loginView model

                LogoutRoute ->
                    loginView model

                ChatRoute ->
                    chatView model

                NotFoundRoute ->
                    notFoundView

        ( layoutClass, contentOnClickCmd ) =
            case model.ui.sideMenuActive of
                True ->
                    ( "active", ToggleSideMenu )

                False ->
                    ( "", NoOp )
    in
        case model.route of
            HomeRoute ->
                homeView model

            LoginRoute ->
                loginView model

            _ ->
                div [ id "layout", class layoutClass ]
                    [ menuLinkItem "#menu" "" "menu-link"
                    , menu model
                    , fixedHeader model "IoT Platform" routingItemNormalHeader
                    , div [ onClick contentOnClickCmd ]
                        [ contentView ]
                    ]


menu : Model -> Html Msg
menu model =
    div [ id "menu" ]
        [ nav [ class "pure-menu" ]
            [ (menuHeading "/" "Labs")
            , ul
                [ class "pure-menu-list" ]
                (List.map (navItem model) (routingItem model.url.src_url))
            ]
        ]


notFoundView : Html Msg
notFoundView =
    div []
        [ text "Page Not Found" ]
