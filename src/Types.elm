module Types exposing (Flags, Model, Msg(..), Screen)

import Array exposing (Array)
import Element exposing (Color)


type alias Model =
    { sqs : Array (Array Color)
    , color : { hex : String, color : Color }
    , wallet : Maybe String
    , set : Maybe ( Int, Int )
    , selectingWallet : Bool
    , screen : Screen
    , about : Bool
    , wide : Bool
    }


type alias Flags =
    { sqs : List (List Int)
    , screen : Screen
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
    | Connect (Maybe Int)
    | ConnectResponse String
    | CloseWallets
    | EditResponse
    | Submit
    | Disconnect
    | ToggleAbout
    | SquareChange (List (List Int))
