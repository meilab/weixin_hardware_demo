module Views.Login exposing (loginView)

import Html exposing (..)
import Html.Attributes exposing (type_, value, class, for, id, placeholder)
import Html.Events exposing (onInput, onSubmit)
import Messages exposing (Msg(..))
import Models exposing (Model)


loginView : Model -> Html Msg
loginView model =
    div []
        [ h3 [] [ text "Login" ]
        , form [ class "pure-form pure-form-aligned", onSubmit AuthRequest ]
            [ fieldset []
                [ div [ class "pure-control-group" ]
                    [ label [ for "name" ] [ text "Username" ]
                    , input
                        [ id "name"
                        , type_ "text"
                        , placeholder "Username"
                        , onInput Username
                        ]
                        []
                    , span [ class "pure-form-message-inline" ] [ text "This is a required field" ]
                    ]
                , div [ class "pure-control-group" ]
                    [ label [ for "name" ] [ text "Username" ]
                    , input
                        [ id "name"
                        , type_ "password"
                        , placeholder "Username"
                        , onInput Username
                        ]
                        []
                    , span [ class "pure-form-message-inline" ] [ text "This is a required field" ]
                    ]
                , div [ class "pure-control-group" ]
                    [ button [ class "pure-button pure-primary-button", type_ "submit" ] [ text "Login" ] ]
                ]
            ]
        ]
