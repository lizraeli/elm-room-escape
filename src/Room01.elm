module Room01 exposing (room01)

import Globals exposing (Object, RoomObjects, Item)


room01 : RoomObjects
room01 =
    [ { name = "Door"
      , needed = [ "key" ]
      , items = []
      , description = "You need a key"
      }
    , { name = "Cellar"
      , needed = [ "flashlight" ]
      , items = [ "key" ]
      , description = "It's dark in there"
      }
    , { name = "Drawers"
      , needed = []
      , items = [ "flashlight" ]
      , description = ""
      }
    ]
