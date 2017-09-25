module Globals exposing (Object, RoomObjects, Item)


type alias Item =
    String


type alias Object =
    { name : String
    , needed : List Item
    , items : List Item
    , description : String
    }


type alias RoomObjects =
    List Object
