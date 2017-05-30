module Types exposing (..)

import Maybe exposing (Maybe)


type alias User =
    { username : String
    , password : String
    , token : Maybe String
    }


type alias AuthResponse =
    { code : String
    , token : String
    }
