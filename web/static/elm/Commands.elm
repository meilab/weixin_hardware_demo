module Commands
    exposing
        ( authRequest
        , deliverMessageCmd
        , chatMessageDecoder
        , userPresenceDecoder
        )

import Http exposing (..)
import Json.Decode as JD
import Json.Encode as JE
import Json.Decode.Pipeline exposing (decode, required, optional)
import Messages exposing (..)
import Types
    exposing
        ( AuthResponse
        , ReceivedChatMessage
        , ChatUserInfo
        , UserPresence
        )
import Helpers exposing (tokenHeader)
import Maybe


authRequest : Maybe String -> String -> String -> String -> Cmd Msg
authRequest token api_url username password =
    Http.request
        { method = "POST"
        , headers = [ (tokenHeader token) ]
        , url = authRequestUrl api_url
        , body = authBody username password
        , expect = authResponseExpect
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send OnAuthCmdResponse


deliverMessageCmd : Maybe String -> String -> String -> Cmd Msg
deliverMessageCmd token api_url chat_str =
    Http.request
        { method = "POST"
        , headers = [ (tokenHeader token) ]
        , url = deliverMessageCmdUrl api_url
        , body = (deliverMessageCmdBody token chat_str)
        , expect = deliverMessageCmdExpect
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send OnDeliverMessageResponse


authRequestUrl : String -> String
authRequestUrl api_url =
    api_url ++ "/auth"


deliverMessageCmdUrl : String -> String
deliverMessageCmdUrl api_url =
    api_url ++ "/chat"



-- CMD encoder


authBody : String -> String -> Body
authBody username password =
    jsonBody
        (JE.object
            [ ( "username", JE.string username )
            , ( "password", JE.string password )
            ]
        )


authResponseExpect : Expect AuthResponse
authResponseExpect =
    expectJson authResponseDecoder


authResponseDecoder : JD.Decoder AuthResponse
authResponseDecoder =
    decode AuthResponse
        |> required "code" JD.string
        |> required "token" JD.string


deliverMessageCmdBody : Maybe String -> String -> Body
deliverMessageCmdBody token str =
    jsonBody
        (JE.object
            [ ( "token", JE.string (token |> Maybe.withDefault "") )
            , ( "message", JE.string str )
            ]
        )


deliverMessageCmdExpect : Expect ReceivedChatMessage
deliverMessageCmdExpect =
    expectJson chatMessageDecoder


chatMessageDecoder : JD.Decoder ReceivedChatMessage
chatMessageDecoder =
    decode ReceivedChatMessage
        |> required "id" JD.int
        |> required "user" chatUserDecoder
        |> required "body" JD.string
        |> required "at" JD.int


chatUserDecoder : JD.Decoder ChatUserInfo
chatUserDecoder =
    decode ChatUserInfo
        |> required "id" JD.int
        |> required "username" JD.string


userPresenceDecoder : JD.Decoder UserPresence
userPresenceDecoder =
    decode UserPresence
        |> required "username" JD.string
