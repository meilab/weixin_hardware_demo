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
import Commands exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Presence exposing (PresenceState, syncState, syncDiff, presenceStateDecoder, presenceDiffDecoder)
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Json.Decode.Pipeline exposing (decode, required, custom)
import Http
import Types exposing (..)


socketServer : String -> String -> String -> String
socketServer token hostname port_ =
    "ws://" ++ hostname ++ ":" ++ "4000" ++ "/socket/websocket?token=" ++ (Http.encodeUri token)


initPhxSocket : String -> String -> String -> String -> Phoenix.Socket.Socket Msg
initPhxSocket token username hostname port_ =
    Phoenix.Socket.init
        (socketServer token hostname port_)
        |> Phoenix.Socket.withDebug


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

                newPhxSocket =
                    initPhxSocket
                        (Maybe.withDefault "111" token)
                        model.user.username
                        model.url.hostname
                        model.url.port_

                newCmd =
                    case token of
                        Just tokenValue ->
                            Cmd.batch
                                [ Navigation.newUrl (model.url.src_url ++ "/chat")
                                , cmd (JoinChannel model.channelName)
                                ]

                        Nothing ->
                            Navigation.newUrl (model.url.src_url ++ "/login")
            in
                ( { model
                    | user = newUser
                    , phxSocket = newPhxSocket
                  }
                , newCmd
                )

        OnAuthCmdResponse (Err error) ->
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

        -- Phoenix Socket related messages
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        MessageInput str ->
            ( { model | newMessage = str }, Cmd.none )

        SendMessage ->
            let
                payload =
                    (JE.object
                        [ ( "at", JE.string "1" )
                        , ( "body", JE.string model.newMessage )
                        ]
                    )

                push_ =
                    Phoenix.Push.init "new_msg" model.channelName
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                ( { model
                    | newMessage = ""
                    , phxSocket = phxSocket
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

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
            ( model, Cmd.none )

        ReceiveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    ( { model | messages = (chatMessage :: model.messages) }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        JoinChannel channelName ->
            let
                channel =
                    Phoenix.Channel.init channelName
                        |> Phoenix.Channel.onJoin (always (ShowJoinedMessage channelName))
                        |> Phoenix.Channel.onClose (always (ShowLeftMessage channelName))

                phxSocketTemp =
                    model.phxSocket
                        |> Phoenix.Socket.on "new_msg" channelName ReceiveChatMessage
                        |> Phoenix.Socket.on "presence_state" channelName HandlePresenceState
                        |> Phoenix.Socket.on "presence_diff" channelName HandlePresenceDiff

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel phxSocketTemp
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        LeaveChannel channelName ->
            let
                phxSocketTemp =
                    model.phxSocket
                        |> Phoenix.Socket.off "new_msg" channelName
                        |> Phoenix.Socket.off "presence_state" channelName
                        |> Phoenix.Socket.off "presence_diff" channelName

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.leave channelName phxSocketTemp
            in
                ( { model
                    | phxSocket = phxSocket
                    , messages = []
                  }
                , Cmd.map PhoenixMsg phxCmd
                )

        ShowJoinedMessage channelName ->
            let
                joinMessage =
                    { id = 1
                    , user =
                        { id = 1
                        , username = model.user.username
                        }
                    , body = "Joined Channel: " ++ channelName
                    , at = 1
                    }
            in
                ( { model | messages = joinMessage :: model.messages }
                , Cmd.none
                )

        ShowLeftMessage channelName ->
            let
                leftMessage =
                    { id = 1
                    , user =
                        { id = 1
                        , username = model.user.username
                        }
                    , body = "Left Channel: " ++ channelName
                    , at = 1
                    }
            in
                ( { model | messages = leftMessage :: model.messages }
                , Cmd.none
                )

        HandlePresenceState raw ->
            case JD.decodeValue (presenceStateDecoder userPresenceDecoder) raw of
                Ok presenceState ->
                    let
                        newPresenceState =
                            model.phxPresences |> syncState presenceState

                        onlineUsers =
                            Dict.keys presenceState
                                |> List.map OnlineUser
                    in
                        ( { model
                            | onlineUsers = onlineUsers
                            , phxPresences = newPresenceState
                          }
                        , Cmd.none
                        )

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
                    in
                        model ! []

        HandlePresenceDiff raw ->
            case JD.decodeValue (presenceDiffDecoder userPresenceDecoder) raw of
                Ok presenceDiff ->
                    let
                        newPresenceState =
                            model.phxPresences |> syncDiff presenceDiff

                        onlineUsers =
                            Dict.keys newPresenceState
                                |> List.map OnlineUser
                    in
                        { model | onlineUsers = onlineUsers, phxPresences = newPresenceState } ! []

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
                    in
                        model ! []

        NoOp ->
            ( model, Cmd.none )
