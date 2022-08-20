module Main exposing (main)

import Browser
import Element
import Ports
import Types exposing (Flags, Model, Msg(..))
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { sqs = Update.parseSquares flags.sqs
      , color =
            { hex = "#000000"
            , color = Element.rgb255 0 0 0
            }
      , wide = flags.screen.width >= 1350
      , wallet = Nothing
      , set = Nothing
      , selectingWallet = False
      , screen = flags.screen
      , about = False
      , editInProg = Nothing
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    [ Ports.connectResponse ConnectResponse
    , Ports.editResponse EditResponse
    , Ports.squareChange SquareChange
    ]
        |> Sub.batch
