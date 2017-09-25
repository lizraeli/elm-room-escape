module Model exposing (Model)

import Globals exposing (Item, Object)

type alias Model =
    { input: String
    , action: String
    , userItems: List Item
    , currentRoom: Int
    , roomObjects: List Object }