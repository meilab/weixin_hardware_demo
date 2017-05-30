module Views.Chat exposing (..)

import Html exposing (Html, form, div, h3, text, ul, li, input)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onSubmit, onInput)
import Messages exposing (Msg(..))
import Models exposing (Model)


chatView : Model -> Html Msg
chatView model =
    div []
        [ h3 [] [ text "Messages:" ]
        , newMessageForm model
        , ul [] ((List.reverse << List.map renderMessage) model.messages)
        ]


newMessageForm : Model -> Html Msg
newMessageForm model =
    form [ onSubmit DeliverMessage ]
        [ input [ type_ "text", value model.newMessage, onInput MessageInput ] []
        ]


renderMessage : String -> Html Msg
renderMessage message =
    li [] [ text message ]