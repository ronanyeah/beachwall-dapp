module Update exposing (parseSquares, size, update)

import Array
import Array.Extra
import Element
import List.Extra
import Maybe.Extra exposing (unwrap)
import Ports
import Types exposing (Model, Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SquareChange data ->
            ( { model
                | sqs = parseSquares data
              }
            , Cmd.none
            )

        SelectCol col ->
            ( { model
                | color =
                    col
                        |> Maybe.withDefault model.color
              }
            , Cmd.none
            )

        ConfirmCol ( x, y ) ->
            ( { model
                | set =
                    if Just ( x, y ) == model.set then
                        Nothing

                    else
                        Just ( x, y )
              }
            , Cmd.none
            )

        Submit ->
            ( model
            , model.set
                |> unwrap Cmd.none
                    (\( x, y ) ->
                        Ports.edit
                            { n = (size * x) + y
                            , col =
                                model.color.color
                                    |> Element.toRgb
                                    |> (\{ red, green, blue } ->
                                            [ red * 255, green * 255, blue * 255 ]
                                       )
                                    |> List.map round
                            }
                    )
            )

        Connect mn ->
            mn
                |> unwrap
                    ( { model | selectingWallet = True }, Cmd.none )
                    (\n ->
                        ( model, Ports.connect n )
                    )

        ConnectResponse w ->
            ( { model | wallet = Just w, set = Nothing }, Cmd.none )

        CloseWallets ->
            ( { model | selectingWallet = False }, Cmd.none )

        ToggleAbout ->
            ( { model | about = not model.about }, Cmd.none )

        Disconnect ->
            ( { model
                | wallet = Nothing
                , set = Nothing
                , selectingWallet = False
              }
            , Ports.disconnect ()
            )

        EditResponse ->
            ( { model
                | sqs =
                    model.set
                        |> unwrap model.sqs
                            (\( x, y ) ->
                                model.sqs
                                    |> Array.Extra.update x
                                        (Array.Extra.update y
                                            (always model.color.color)
                                        )
                            )
              }
            , Cmd.none
            )


size : Int
size =
    40


parseSquares =
    List.filterMap
        (\col ->
            case col of
                [ a, b, c ] ->
                    Element.rgb255 a b c
                        |> Just

                _ ->
                    Nothing
        )
        >> List.Extra.groupsOf size
        >> List.map Array.fromList
        >> Array.fromList
