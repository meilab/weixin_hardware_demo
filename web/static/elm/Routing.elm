module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import Maybe exposing (Maybe)
import Html exposing (Html, text)
import Array exposing (Array)
import Dict exposing (Dict)


type Route
    = HomeRoute
    | LoginRoute
    | LogoutRoute
    | ChatRoute
    | NotFoundRoute

parseAppend : String -> Parser a a -> Parser a a
parseAppend src_url item =
  case src_url of
    "" ->
      item
    _ ->
      src_url
      |> String.dropLeft 1
      |> String.split "/"
      |> List.map ( s )
      |> List.reverse
      |> List.foldl ( </> )( item )

matchers : String -> Parser(Route -> a) a
matchers src_url =
  oneOf
    [ map HomeRoute ( parseAppend src_url top )
    , map LoginRoute ( parseAppend src_url ( s "login" ) )
    , map LogoutRoute ( parseAppend src_url ( s "logout" ) )
    , map ChatRoute ( parseAppend src_url ( s "chat" ) )
    ]

parseLocation : Location -> String -> Route
parseLocation location src_url =
  case ( parsePath ( matchers src_url ) location ) of
    Just route ->
      route
    Nothing ->
      NotFoundRoute

urlFor : String -> Route -> String
urlFor src_url route =
  case route of
    HomeRoute ->
      src_url
    LoginRoute ->
      src_url ++ "/login"
    LogoutRoute ->
      src_url ++ "/logout"
    ChatRoute ->
      src_url ++ "/chat"
    NotFoundRoute ->
      src_url

routingItem : String -> List ( String, String, Route, String )
routingItem src_url =
  [ ("Chat", "", ChatRoute, src_url ++ "/chat")
  , ("Login", "", LoginRoute, src_url ++ "/login")
  ]

routingItemHomePage : String -> List ( String, String, Route, String )
routingItemHomePage src_url =
  routingItem src_url

routingItemNormalHeader : String -> List ( String, String, Route, String )
routingItemNormalHeader src_url =
  routingItem src_url

tabsTitles : String -> List (Html a)
tabsTitles src_url =
  routingItem src_url
  |> List.map(\(title, _, _, _) -> (text title))


tabsUrls : String -> Array String
tabsUrls src_url =
  routingItem src_url
  |> List.map(\(_, _, _, url) -> url)
  |> Array.fromList


urlTabs : String -> Dict String Int
urlTabs src_url =
  routingItem src_url
  |> List.indexedMap (\idx (_, _, _, url) -> (url, idx))
  |> Dict.fromList

