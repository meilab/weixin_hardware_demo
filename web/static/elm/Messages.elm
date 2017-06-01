module Messages exposing (..)

import Navigation exposing (Location)
import Types exposing (..)
import Http
import Phoenix.Socket
import Json.Encode as JE


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
    | OnDeliverMessageResponse (Result Http.Error ReceivedChatMessage)
    | SendMessage
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveChatMessage JE.Value
    | JoinChannel String
    | LeaveChannel String
    | ShowJoinedMessage String
    | ShowLeftMessage String
    | HandlePresenceState JE.Value
    | HandlePresenceDiff JE.Value
    | NoOp
