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


type alias UserPresence =
    { username : String
    }


type alias ChatMessage =
    { user : String
    , body : String
    }


type alias ChatUserInfo =
    { id : Int
    , username : String
    }


type alias ReceivedChatMessage =
    { id : Int
    , user : ChatUserInfo
    , body : String
    , at : Int
    }


type alias OnlineUser =
    { username : String
    }
