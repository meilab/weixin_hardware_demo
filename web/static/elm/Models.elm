module Models exposing (..)

import Routing exposing (Route)
import Maybe exposing (Maybe)
import Types exposing (..)


type alias Url =
    { origin : String
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
    , newMessage : String
    , messages : List String
    }


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
    , newMessage = ""
    , messages = []
    }
