module Main exposing (..)

import Views exposing (view)
import Models exposing (..)
import Messages exposing (Msg(..))
import Update exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation, urlTabs)
import Dict exposing (Dict)
import Phoenix.Socket


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        src_url =
            case
                location.pathname
                    |> String.split "/"
                    |> List.reverse
                    |> List.tail
                    |> Maybe.map (List.reverse)
                    |> Maybe.map (String.join "/")
            of
                Just url ->
                    url

                Nothing ->
                    ""

        currentRoute =
            parseLocation location src_url

        selectedMenuTab =
            Dict.get location.pathname (urlTabs src_url)
                |> Maybe.withDefault -1

        url =
            { origin = location.origin
            , hostname = location.hostname
            , port_ = location.port_
            , src_url = src_url
            , api_url = location.origin ++ "/api/v1/iot"
            }

        initCommand =
            changeUrlCommand (initialModel currentRoute url selectedMenuTab) currentRoute
    in
        ( initialModel currentRoute url selectedMenuTab, initCommand )


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg
