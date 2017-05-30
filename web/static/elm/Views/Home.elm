module Views.Home exposing (homeView)

import Html exposing (Html, form, img, button, i, h1, h2, h3, h4, p, span, a, div, ul, li, text, nav, header, fieldset, label, input)
import Html.Attributes exposing (type_, value, class, for, id, placeholder, width, alt, src)
import Html.Events exposing (onInput, onSubmit)
import Messages exposing (Msg(..))
import Models exposing (Model)
import Json.Decode as JD exposing (..)
import ViewHelpers exposing (fixedHeader, linkItem)
import Routing exposing (routingItemHomePage)


homeView : Model -> Html Msg
homeView model =
    div []
        [ fixedHeader model "Meilab" routingItemHomePage
        , splash

        -- , mapView model
        , content model
        ]


splash : Html Msg
splash =
    div [ class "splash-container" ]
        [ div [ class "splash" ]
            [ h1 [ class "splash-head" ] [ text "meilab" ]
            , p [ class "splash-subhead" ] [ text "前沿技术培训 项目咨询" ]
            , p []
                [ linkItem "/chat" "Get Started" "pure-button pure-button-primary" ]
            ]
        ]


content : Model -> Html Msg
content model =
    div [ class "content-wrapper" ]
        [ projects
        , services
        , contact
        , footer
        ]


contact : Html Msg
contact =
    div [ class "content" ]
        [ contentHead "Meta Info"
        , contactDetail
        ]


projects : Html Msg
projects =
    div [ class "content" ]
        [ contentHead "相关项目"
        , projectsDetail
        ]


services : Html Msg
services =
    div [ class "ribbon l-box-lrg pure-g" ]
        [ div [ class "l-box-lrg is-center pure-u-1 pure-u-md-1-2 pure-u-lg-2-5" ]
            [ img
                [ width 300
                , alt "File Icons"
                , class "pure-img-responsive"
                , src "images/phoenix.png"
                ]
                []
            ]
        , div [ class "pure-u-1 pure-u-md-1-2 pure-u-lg-3-5" ]
            [ h2 [ class "content-head content-head-ribbon" ] [ text "提供服务" ]
            , p [] [ text "项目开发 培训 咨询" ]
            ]
        ]


projectsDetail : Html Msg
projectsDetail =
    div [ class "pure-g" ]
        [ div [ class "l-box pure-u-1 pure-u-md-1-2 pure-u-lg-1-4" ]
            [ h3 [ class "content-subhead" ]
                [ i [ class "fa fa-mobile" ] []
                , text "物联网平台"
                ]
            , p [] [ text "智能连接一切设备，实时追踪，控制" ]
            , p [] [ text "技术栈：Elixir, MQTT, Elm, C, React-Native" ]
            ]
        , div [ class "l-box pure-u-1 pure-u-md-1-2 pure-u-lg-1-4" ]
            [ h3 [ class "content-subhead" ]
                [ i [ class "fa fa-rocket" ] []
                , text "微信公众平台"
                ]
            , p [] [ text "通过微信公众号管理物联网终端" ]
            , p [] [ text "技术栈：Elixir, C, Weixin, Elm" ]
            ]
        , div [ class "l-box pure-u-1 pure-u-md-1-2 pure-u-lg-1-4" ]
            [ h3 [ class "content-subhead" ]
                [ i [ class "fa fa-th-large" ] []
                , text "微信小程序"
                ]
            , p [] [ text "通过微信小程序管理物联网终端" ]
            , p [] [ text "技术栈：Elixir, C, JavaScript, Socket" ]
            ]
        , div [ class "l-box pure-u-1 pure-u-md-1-2 pure-u-lg-1-4" ]
            [ h3 [ class "content-subhead" ]
                [ i [ class "fa fa-check-square-o" ] []
                , text "聊天机器人"
                ]
            , p [] [ text "智能聊天机器人" ]
            , p [] [ text "技术栈：Elixir, NLP, Elm" ]
            ]
        ]


contactDetail : Html Msg
contactDetail =
    div [ class "pure-g" ]
        [ div [ class "l-box-lrg pure-u-1 pure-u-md-2-5" ]
            [ form [ class "pure-form pure-form-stacked" ]
                [ fieldset []
                    [ label [ for "name" ] [ text "Your Name" ]
                    , input [ type_ "text", placeholder "Your Name" ] []
                    , label [ for "email" ] [ text "Your Email" ]
                    , input [ type_ "text", placeholder "Your Email" ] []
                    , label [ for "password" ] [ text "Your Password" ]
                    , input [ type_ "text", placeholder "Your Password" ] []
                    , button [ type_ "submit", class "pure-button" ] [ text "Sign Up" ]
                    ]
                ]
            ]
        , div [ class "l-box-lrg pure-u-1 pure-u-md-3-5" ]
            [ h4 [] [ text "Contact Us" ]
            , p [] [ text "Meilab" ]
            , h4 [] [ text "More Info" ]
            , p [] [ text "Meilab： 提供最前沿的物联网行业解决方案，培训，咨询服务" ]
            ]
        ]


footer : Html Msg
footer =
    div [ class "footer l-box is-center" ]
        [ text "Meilab" ]


contentHead : String -> Html Msg
contentHead str =
    h2 [ class "content-head is-center" ] [ text str ]



-- div []
--     [ mapView model
--     ]
