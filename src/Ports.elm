port module Ports exposing (..)

-- OUT


port connect : () -> Cmd msg


port log : String -> Cmd msg


port edit : { n : Int, col : List Int } -> Cmd msg



-- IN


port connectResponse : (String -> msg) -> Sub msg


port disconnect : (() -> msg) -> Sub msg


port editResponse : (Bool -> msg) -> Sub msg


port squareChange : (List (List Int) -> msg) -> Sub msg
