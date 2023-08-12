module Types exposing (Flags, Model, Msg(..), Screen)

import Array exposing (Array)
import Element exposing (Color)


type alias Model =
    { sqs : Array (Array Color)
    , color : { hex : String, color : Color }
    , wallet : Maybe String
    , set : Maybe ( Int, Int )
    , screen : Screen
    , about : Bool
    , wide : Bool
    , editInProg : Maybe ( Color, ( Int, Int ) )
    }


type alias Flags =
    { sqs : List (List Int)
    , screen : Screen
    , wallet : Maybe String
    }


type alias Screen =
    { width : Int
    , height : Int
    }


type Msg
    = SelectCol
        (Maybe
            { hex : String
            , color : Color
            }
        )
    | ConfirmCol ( Int, Int )
    | Connect
    | ConnectResponse String
    | EditResponse Bool
    | Submit ( Int, Int )
    | Disconnect
    | ToggleAbout
    | SquareChange (List (List Int))
