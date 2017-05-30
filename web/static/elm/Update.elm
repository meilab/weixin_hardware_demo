module Update exposing (..)

import Messages exposing (Msg(..))
import Models
    exposing
        ( Model
        , initialUser
        , Ui
        )
import Navigation
import Routing exposing (Route(..), parseLocation, tabsUrls, urlTabs)
import Array exposing (Array)
import Dict exposing (Dict)
import Helpers exposing (cmd)
import Commands exposing (authRequest, deliverMessageCmd)


changeUrlCommand : Model -> Route -> Cmd Msg
changeUrlCommand model route =
    case model.user.token of
        Nothing ->
            case route of
                HomeRoute ->
                    Cmd.none

                LoginRoute ->
                    Cmd.none

                ChatRoute ->
                    Cmd.none

                _ ->
                    Navigation.newUrl (model.url.src_url ++ "/login")

        Just token ->
            changeUrlCommandAfterLogin model route


changeUrlCommandAfterLogin : Model -> Route -> Cmd Msg
changeUrlCommandAfterLogin model route =
    case route of
        LogoutRoute ->
            Navigation.newUrl (model.url.src_url ++ "/")

        _ ->
            Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectedMenuTab num ->
            let
                url =
                    Array.get num (tabsUrls model.url.src_url)
                        |> Maybe.withDefault model.url.src_url
            in
                ( { model | ui = (Ui num model.ui.sideMenuActive) }, Navigation.newUrl url )

        NewUrl url ->
            model ! [ (Navigation.newUrl url) ]

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location model.url.src_url

                newUser =
                    case newRoute of
                        LogoutRoute ->
                            initialUser

                        _ ->
                            model.user

                newSelectedMenuTab =
                    Dict.get location.pathname (urlTabs model.url.src_url)
                        |> Maybe.withDefault -1
            in
                ( { model | route = newRoute, ui = Ui newSelectedMenuTab model.ui.sideMenuActive, user = newUser }
                , changeUrlCommand model newRoute
                )

        AuthRequest ->
            ( model
            , authRequest
                model.user.token
                model.url.api_url
                model.user.username
                model.user.password
            )

        OnAuthCmdResponse (Ok responseInfo) ->
            let
                token =
                    case responseInfo.code of
                        "200" ->
                            Just responseInfo.token

                        _ ->
                            Nothing

                newUser =
                    { username = model.user.username
                    , password = model.user.password
                    , token = token
                    }

                newCmd =
                    case token of
                        Just tokenValue ->
                            Navigation.newUrl (model.url.src_url ++ "/chat")

                        Nothing ->
                            Cmd.none
            in
                ( { model | user = newUser }, newCmd )

        OnAuthCmdResponse (Err error) ->
            Debug.log (toString (error))
                ( model, Cmd.none )

        Logout ->
            ( { model | user = initialUser }, Navigation.newUrl (model.url.src_url ++ "login") )

        Username username ->
            let
                newUser =
                    { username = username
                    , password = model.user.password
                    , token = model.user.token
                    }
            in
                ( { model | user = newUser }, Cmd.none )

        Password password ->
            let
                newUser =
                    { username = model.user.username
                    , password = password
                    , token = model.user.token
                    }
            in
                ( { model | user = newUser }, Cmd.none )

        ToggleSideMenu ->
            ( { model | ui = Ui model.ui.selectedMenuTab (not model.ui.sideMenuActive) }
            , Cmd.none
            )

        MessageInput str ->
            ( { model | newMessage = str }, Cmd.none )

        DeliverMessage ->
            ( { model | newMessage = "" }
            , deliverMessageCmd
                model.user.token
                model.url.api_url
                model.newMessage
            )

        OnDeliverMessageResponse (Ok responseInfo) ->
            ( { model | messages = responseInfo :: model.messages }, Cmd.none )

        OnDeliverMessageResponse (Err error) ->
            Debug.log (toString (error))
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
