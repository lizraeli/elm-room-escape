module Main exposing (..)

import Html exposing (Html, Attribute, div, h4, input, text, ul, li, p, u)
import Html.Attributes exposing (placeholder, style, value, id)
import Html.Events exposing (onInput, onClick)
import Html.Events.Extra exposing (onEnter)
import Dom
import Task
import Globals exposing (Object, RoomObjects, Item)
import Model exposing (Model)
import Actions exposing (doAction)
import Room01 exposing (room01)
import Debug


---- MODEL ----


model : Model
model =
    Model "" "" [ "watch" ] 1 room01


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )



-- UPDATE


type Msg
    = NewInput String
    | Submit
    | Focus
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Focus ->
            ( model
            , Task.attempt (\_ -> NoOp) (Dom.focus "input")
            )

        NewInput input ->
            ( { model | input = autoComplete input model }
            , Cmd.none
            )

        Submit ->
            ( doAction model.input model
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ myStyle, onClick Focus ]
        [ h4 [] [ text "Escape the Room" ]
        , ul [ small ]
            [ li [] [ text "use item object" ]
            , li [] [ text "examine object" ]
            ]
        , input [ id "input", value model.input, onEnter Submit, onInput NewInput, myStyle ] []
        , p [ myStyle ] [ text model.action ]
        , p [ myStyle ] [ u [] [ text "You see" ] ]
        , ul [] (listRoomObjects model.roomObjects)
        , p [ myStyle ] [ u [] [ text "Your Items " ] ]
        , ul [] (listItems model.userItems)
        ]


myStyle : Attribute msg
myStyle =
    style
        [ ( "height", "40px" )
        , ( "padding", "10px 0" )
        , ( "font-size", "1.2em" )
        , ( "margin", "10px" )
        ]


small : Attribute msg
small =
    style
        [ ( "padding", "10px 0" )
        , ( "font-size", "0.8em" )
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }



--


listRoomObjects : List Object -> List (Html msg)
listRoomObjects objects =
    List.map (\object -> li [] [ text object.name ]) objects


listItems : List Item -> List (Html msg)
listItems items =
    List.map (\item -> li [] [ text item ]) items


actions : List String
actions =
    [ "examine", "use" ]


autoComplete : String -> Model -> String
autoComplete input model =
    let
        words =
            String.words input
    in
        case words of
            [ actionName ] ->
                let
                    userAction =
                        actions
                            |> List.filter (\action -> String.startsWith actionName action)
                            |> List.head
                in
                    case userAction of
                        Just str ->
                            if (String.length actionName > 2) then
                                str ++ " "
                            else
                                actionName

                        Nothing ->
                            input

            _ ->
                input
