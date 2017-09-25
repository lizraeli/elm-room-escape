module Actions exposing (doAction)

import Model exposing (Model)
import Globals exposing (..)


doAction : String -> Model -> Model
doAction action model =
    let
        newModel =
            { model | input = "", action = "invalid action" }

        words =
            String.words action
    in
        case words of
            [] ->
                newModel

            [ x ] ->
                newModel

            [ actionName, objectName ] ->
                case actionName of
                    "examine" ->
                        examineAction objectName newModel

                    _ ->
                        newModel

            [ actionName, itemName, objectName ] ->
                case actionName of
                    "use" ->
                        useAction itemName objectName newModel

                    _ ->
                        newModel

            _ ->
                newModel



-- Examine Object


examineAction : String -> Model -> Model
examineAction objectName model =
    let
        roomObject =
            getRoomObject objectName model
    in
        case roomObject of
            Just object ->
                examineObject object model

            Nothing ->
                { model
                    | action = objectName ++ " not found in this room."
                }


getRoomObject : String -> Model -> Maybe Object
getRoomObject objectName model =
    let
        name =
            String.toLower objectName

        roomObject =
            List.filter (\object -> String.toLower object.name == name) model.roomObjects
                |> List.head
    in
        roomObject


examineObject : Object -> Model -> Model
examineObject object model =
    case object.needed of
        [] ->
            tryToGetItems object model

        _ ->
            { model | action = object.description }


tryToGetItems : Object -> Model -> Model
tryToGetItems object model =
    let
        numOfItems =
            List.length object.items
    in
        case numOfItems of
            0 ->
                if object.name == "Door" then
                    { model | action = "You're free!" }
                else
                    { model | action = "No items found in " ++ String.toLower object.name }

            _ ->
                getItems object model


getItems : Object -> Model -> Model
getItems object model =
    let
        itemsStr =
            List.foldr (\items item -> items ++ ", " ++ item) "" object.items
    in
        { model
            | action = "got items: " ++ itemsStr
            , userItems = List.concat [ model.userItems, object.items ]
            , roomObjects = mapRemoveItems model.roomObjects object.name
        }


mapRemoveItems : List Object -> String -> List Object
mapRemoveItems objects name =
    let
        removeIfMatch object =
            if object.name == name then
                { object | items = [] }
            else
                object
    in
        List.map removeIfMatch objects



-- Use Item


useAction : Item -> String -> Model -> Model
useAction item objectName model =
    let
        userItem =
            getItemFromInventory item model.userItems

        roomObject =
            getRoomObject objectName model
    in
        case userItem of
            Just item ->
                case roomObject of
                    Just object ->
                        tryToUseItem item object model

                    Nothing ->
                        { model
                            | action = objectName ++ " not found in this room."
                        }

            Nothing ->
                { model
                    | action = "item not found in inventory"
                }


getItemFromInventory : Item -> List Item -> Maybe Item
getItemFromInventory item userItems =
    let
        searchItem =
            String.toLower item

        userItem =
            List.filter (\item -> String.toLower item == searchItem) userItems
                |> List.head
    in
        userItem


tryToUseItem : Item -> Object -> Model -> Model
tryToUseItem item object model =
    let
        neededItem =
            List.filter (\objItem -> objItem == item) object.needed
                |> List.head
    in
        case neededItem of
            Just item ->
                { model
                    | action = "used " ++ item ++ " with " ++ object.name
                    , roomObjects = mapRemoveNeeded item object model.roomObjects
                }

            Nothing ->
                { model
                    | action = "could not use " ++ item ++ " on " ++ object.name
                }


mapRemoveNeeded : Item -> Object -> List Object -> List Object
mapRemoveNeeded item object roomObjects =
    let
        updatedNeeded =
            List.filter (\itemNeeded -> itemNeeded /= item) object.needed

        updatedObject =
            { object
                | needed = updatedNeeded
            }

        matchUpdateObject roomObject =
            if roomObject.name == object.name then
                updatedObject
            else
                roomObject
    in
        List.map matchUpdateObject roomObjects
