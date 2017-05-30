module Messages exposing (..)

import Navigation exposing (Location)
import Types exposing (..)
import Http


type Msg
    = SelectedMenuTab Int
    | NewUrl String
    | OnLocationChange Location
    | AuthRequest
    | OnAuthCmdResponse (Result Http.Error AuthResponse)
    | Logout
    | Username String
    | Password String
    | ToggleSideMenu
    | DeliverMessage
    | MessageInput String
    | OnDeliverMessageResponse (Result Http.Error String)
    | NoOp
