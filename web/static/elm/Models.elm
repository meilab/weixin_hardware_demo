module Models exposing (..)

import Routing exposing (Route)
import Maybe exposing (Maybe)
import Types exposing (..)
import Messages exposing (Msg)
import Phoenix.Socket
import Phoenix.Presence exposing (PresenceState)
import Dict exposing (Dict)


type alias Url =
    { origin : String
    , hostname : String
    , port_ : String
    , src_url : String
    , api_url : String
    }


type alias Ui =
    { selectedMenuTab : Int
    , sideMenuActive : Bool
    }


type alias Model =
    { route : Route
    , url : Url
    , ui : Ui
    , user : User
    , onlineUsers : List OnlineUser
    , newMessage : String
    , messages : List ReceivedChatMessage
    , channelName : String
    , phxSocket : Phoenix.Socket.Socket Msg
    , phxPresences : PresenceState UserPresence
    }


initialPhxSocket : String -> Phoenix.Socket.Socket msg
initialPhxSocket serverUrl =
    Phoenix.Socket.init serverUrl


initialUser : User
initialUser =
    { username = ""
    , password = ""
    , token = Nothing
    }


initialModel : Route -> Url -> Int -> Model
initialModel route url selectedMenuTab =
    { route = route
    , url = url
    , ui = Ui selectedMenuTab False
    , user = initialUser
    , onlineUsers = []
    , newMessage = ""
    , messages = []
    , channelName = "room:1"
    , phxSocket = initialPhxSocket "PATH_TO_SERVER"
    , phxPresences = Dict.empty
    }
