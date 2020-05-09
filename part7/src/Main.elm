module Main exposing (..)

import Auth
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href, property, target, value)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline exposing (..)


main =
    Browser.element
        { init = initialModel
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }


searchFeed : String -> Cmd Msg
searchFeed query =
    let
        url =
            "https://api.github.com/search/repositories?access_token="
                ++ Auth.token
                ++ "&q="
                ++ query
                ++ "+language:elm&sort=stars&order=desc"
    in
    Http.get { url = url, expect = Http.expectJson HandleSearchResponse responseDecoder }


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    Json.Decode.at [ "items" ] (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    succeed SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    }


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { query = "tutorial"
      , results = []
      , errorMessage = Nothing
      }
    , searchFeed "tutorial"
    )


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , input [ class "search-query", onInput SetQuery, value model.query ] []
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , viewErrorMessage model.errorMessage
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewErrorMessage : Maybe String -> Html Msg
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ span [ class "star-count" ] [ text (String.fromInt result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]


type Msg
    = Search
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (Result Http.Error (List SearchResult))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchFeed model.query )

        HandleSearchResponse result ->
            case result of
                Ok results ->
                    ( { model | results = results, errorMessage = Nothing }, Cmd.none )

                Err error ->
                    let
                        errorMessage =
                            case error of
                                Http.BadUrl url ->
                                    "Invalid test URL: " ++ url

                                Http.Timeout ->
                                    "Timed out trying to contact GitHub. Check your Internet connection?"

                                Http.NetworkError ->
                                    "Network error. Check your Internet connection?"

                                Http.BadStatus statCode ->
                                    case statCode of
                                        401 ->
                                            "Auth.elm does not have a valid token. :( Try recreating Auth.elm by following the steps in the README under the section “Create a GitHub Personal Access Token”."

                                        _ ->
                                            "GitHub's Search API returned an error: "
                                                ++ String.fromInt statCode

                                Http.BadBody mess ->
                                    "Something is misconfigured: " ++ mess
                    in
                    ( { model | errorMessage = Just errorMessage }, Cmd.none )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        DeleteById idToHide ->
            let
                newResults =
                    model.results
                        |> List.filter (\{ id } -> id /= idToHide)

                newModel =
                    { model | results = newResults }
            in
            ( newModel, Cmd.none )
