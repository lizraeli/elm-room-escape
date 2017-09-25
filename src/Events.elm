module Events exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on, keyCode)
import Json.Decode as Json 

onKeyPress : (Int -> msg) -> Attribute msg
onKeyPress tagger =
    on "keypress" (Json.map tagger keyCode)