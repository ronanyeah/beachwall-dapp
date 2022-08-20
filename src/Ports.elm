port module Ports exposing (connect, connectResponse, disconnect, edit, editResponse, squareChange)

-- OUT


port connect : Int -> Cmd msg


port disconnect : () -> Cmd msg


port edit : { n : Int, col : List Int } -> Cmd msg



-- IN


port connectResponse : (String -> msg) -> Sub msg


port editResponse : (Bool -> msg) -> Sub msg


port squareChange : (List (List Int) -> msg) -> Sub msg
