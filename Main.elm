module Main exposing (..)

{-| THIS FILE IS NOT PART OF THE WORKSHOP! It is only to verify that you
have everything set up properly.
-}

import Auth
import Browser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string, succeed)
import Json.Decode.Pipeline exposing (..)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = "Verifying setup..." }, searchFeed )


type alias Model =
    { status : String }


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


searchFeed : Cmd Msg
searchFeed =
    let
        url =
            "https://api.github.com/search/repositories?q=test&access_token=" ++ Auth.token
    in
    Http.get { url = url, expect = Http.expectJson Response responseDecoder }


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    Json.Decode.at [ "items" ] (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    succeed SearchResult
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "full_name" Json.Decode.string
        |> Json.Decode.Pipeline.required "stargazers_count" Json.Decode.int


view : Model -> Html Msg
view model =
    div [ class "content", style "text-align" "center" ]
        [ header [] [ h1 [] [ text "Elm Workshop" ] ]
        , div
            [ style "font-size" "48px"
            , style "text-align" "center"
            , style "padding" "48px"
            ]
            [ text model.status ]
        ]


type Msg
    = Response (Result Http.Error (List SearchResult))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Response (Ok _) ->
            ( { status = "You're all set!" }, Cmd.none )

        Response (Err err) ->
            let
                status =
                    case err of
                        Http.Timeout ->
                            "Timed out trying to contact GitHub. Check your Internet connection?"

                        Http.NetworkError ->
                            "Network error. Check your Internet connection?"

                        Http.BadUrl url ->
                            "Invalid test URL: " ++ url

                        Http.BadBody mess ->
                            "Something is misconfigured: " ++ mess

                        Http.BadStatus stat ->
                            case stat of
                                401 ->
                                    "Auth.elm does not have a valid token. :( Try recreating Auth.elm by following the steps in the README under the section “Create a GitHub Personal Access Token”."

                                _ ->
                                    "GitHub's Search API returned an error: "
                                        ++ String.fromInt stat
            in
            ( { status = status }, Cmd.none )
