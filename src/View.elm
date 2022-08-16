module View exposing (view)

import Array
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Helpers.View exposing (cappedHeight, cappedWidth, style, when, whenAttr)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Maybe.Extra exposing (unwrap)
import SolidColor
import Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    (if model.wide then
        [ [ viewTop model
          , viewSelect model
                |> when (model.wallet /= Nothing)
          ]
            |> column [ centerY, spaceEvenly, height <| px 400 ]
        , viewCanvas model
            |> el [ centerY ]
        ]
            |> row [ spacing 100, centerX, height fill ]

     else
        [ viewTop model
            |> el [ centerX ]
        , viewCanvas model
        , viewSelect model
            |> when (model.wallet /= Nothing)
        ]
            |> column
                [ spacing 20
                , height fill
                , width fill
                ]
    )
        |> Element.layoutWith
            { options =
                [ Element.focusStyle
                    { borderColor = Nothing
                    , backgroundColor = Nothing
                    , shadow = Nothing
                    }
                ]
            }
            [ width fill
            , height fill
            , viewAbout
                |> inFront
                |> whenAttr model.about

            --, Background.image "/bg.jpeg"
            , Background.gradient
                { angle = degrees 0
                , steps =
                    [ rgb255 70 30 82
                    , rgb255 0 0 0
                    ]
                }

            --, padding 80
            , padding 20
            , Font.family
                [ Font.typeface "Asap Condensed"

                --[ Font.typeface "Noto Sans Mono"
                ]
            ]


viewTop model =
    [ [ text "🌴"
            |> el
                [ Font.size
                    (if model.wide then
                        65

                     else
                        45
                    )
                ]
      , gradientText "BEACHWALL"
            |> el
                [ Font.size
                    (if model.wide then
                        65

                     else
                        45
                    )
                ]
      ]
        |> row
            [ centerX
            , spacing 10
            , Font.family
                [ Font.typeface "Permanent Marker"

                --[ Font.typeface "Iosevka"
                ]
            , Font.size 45
            ]
    , paragraph [ centerX, Font.color white, width fill, Font.center ]
        [ text "Collaborative art on the blockchain. "
            |> el
                [ Font.size
                    (if model.wide then
                        22

                     else
                        17
                    )
                ]
        , Input.button
            [ hover
            , Font.underline
            , Font.size
                (if model.wide then
                    22

                 else
                    17
                )
            ]
            { onPress = Just ToggleAbout, label = text "Learn more" }
        ]
        |> when (model.wallet == Nothing || model.wide)
    , model.wallet
        |> unwrap
            (if not model.selectingWallet then
                btn "👆 Connect Wallet" (Connect Nothing)
                    |> el [ centerX, fadeIn ]

             else
                List.range 0 3
                    |> List.map
                        (\n ->
                            btn
                                (case n of
                                    0 ->
                                        "Phantom"

                                    1 ->
                                        "Solflare"

                                    2 ->
                                        "Glow"

                                    _ ->
                                        "Ledger"
                                )
                                (Connect (Just n))
                        )
                    |> (\xs -> xs ++ [ btn "𐄂" CloseWallets ])
                    |> wrappedRow [ spacing 10, centerX ]
            )
            (String.left 11
                >> (\addr ->
                        [ [ text "Connected"
                                |> el [ Font.size 20, Font.italic ]
                          , addr
                                ++ "..."
                                |> text
                                |> el [ Font.size 23 ]
                          ]
                            |> column [ spacing 5 ]
                        , btn "𐄂" Disconnect
                        ]
                   )
                >> row [ padding 10, spacing 10, Background.color grey, centerX, fadeIn ]
            )
    ]
        |> column [ spacing 20, fadeIn ]


gradientText : String -> Element msg
gradientText txt =
    [ Html.text txt ]
        |> Html.div
            [ Html.Attributes.style
                "-webkit-text-stroke"
                (String.fromFloat 1.2 ++ "px rgb(118, 78, 1)")
            , Html.Attributes.style
                "background-image"
                """linear-gradient(
                    to bottom,
                    rgb(70, 30, 82) 26%,
                    rgb(221, 81, 127) 78%
                )"""

            --rgb(255, 214, 0) 26%,
            --rgb(185, 117, 14) 78%
            , Html.Attributes.style "-webkit-background-clip" "text"
            , Html.Attributes.style "background-clip" "text"
            , Html.Attributes.style "-webkit-text-fill-color" "transparent"
            ]
        |> html
        |> el []


white =
    rgb255 255 255 255


black =
    rgb255 0 0 0


toHex : Color -> String
toHex =
    Element.toRgb
        >> (\{ red, green, blue } ->
                SolidColor.fromRGB ( red * 255, green * 255, blue * 255 )
           )
        >> SolidColor.toHex


fromHex : String -> Maybe Color
fromHex =
    SolidColor.fromHex
        >> Result.toMaybe
        >> Maybe.map
            (SolidColor.toRGB
                >> (\( r, g, b ) ->
                        Element.rgb255
                            (round r)
                            (round g)
                            (round b)
                   )
            )


btn : String -> msg -> Element msg
btn txt msg =
    Input.button
        [ padding 10
        , hover
        , Border.width 2
        , Background.color white
        , Font.size 22
        , Border.shadow
            { blur = 0
            , color = grey
            , offset = ( 4, 4 )
            , size = 0
            }
        ]
        { onPress = Just msg
        , label = text txt
        }


hover : Attribute msg
hover =
    --Element.mouseOver [ Background.color <| rgb255 100 100 100 ]
    Element.mouseOver [ fade ]


fade : Element.Attr a b
fade =
    Element.alpha 0.7


grey =
    rgb255 220 220 220


viewPair : String -> Element msg -> Element msg
viewPair txt elem =
    [ text txt
        |> el [ Font.size 20, Font.bold ]
    , elem
    ]
        |> column [ spacing 10 ]


viewAbout =
    [ text "About"
        |> el [ Font.size 35, Font.bold, centerX ]
    , newTabLink [ hover ]
        { url = "https://twitter.com/onthebeachwall"
        , label = text "🐦  @onthebeachwall"
        }
    , el [ width fill, height <| px 1, Background.color black ] none
    , para "Beachwall is a collaborative pixel art canvas stored on the Solana blockchain."
    , para "There are 1600 (40x40) squares which can be changed to any color using a Solana transaction."
    , para "Beachwall is currently live on Mainnet, and is being developed as a contribution to Solana Summer Camp."
    , el [ width fill, height <| px 1, Background.color black ] none
    , viewPair "Will this be open source?"
        (para "Yes, the frontend and smart contract code will be made public soon.")
    , viewPair "Where is the contract?"
        (newTabLink [ Font.underline, hover ]
            { url = "https://explorer.solana.com/address/BW1oTSjMPxvqXjzvtyL1pzb8bwa1XHkdLaHwLC2yV1Ur"
            , label = text "BW1oTSjMPxvqXjzvty..."
            }
        )
    , viewPair "Who built this?"
        (newTabLink [ Font.underline ]
            { url = "https://ronanmccabe.app/"
            , label = text "Me."
            }
        )

    --, viewPair "Where can I get Devnet SOL?"
    --(newTabLink [ Font.underline, hover ]
    --{ url = "https://solfaucet.com/"
    --, label = text "Sol Faucet."
    --}
    --)
    ]
        |> column
            [ width fill
            , height fill
            , scrollbarY
            , spacing 20
            , padding 20
            , fadeIn
            , Input.button
                [ alignRight
                , alignTop
                , padding 10
                , Font.size 35
                , hover
                ]
                { onPress = Just ToggleAbout
                , label = text "𐄂"
                }
                |> inFront
            ]
        |> el [ height <| px 575, Background.color grey, width fill, Border.width 4 ]
        |> el [ padding 10, cappedWidth 800, centerX ]


viewCanvas model =
    model.sqs
        |> Array.toList
        |> List.indexedMap
            (\n ->
                Array.toList
                    >> List.indexedMap
                        (\n2 col ->
                            --Element.Lazy.lazy3
                            --(\a b c ->
                            Input.button
                                [ height <| px 20
                                , width <| px 20

                                --[ height <| px 10
                                --, width <| px 10
                                , Background.color col
                                , text "🖌️"
                                    |> el [ Font.size 10, centerX, centerY ]
                                    |> el
                                        [ width fill
                                        , height fill
                                        , Border.width 1

                                        --, Border.glow (rgb255 100 200 75) 3
                                        ]
                                    |> inFront
                                    |> whenAttr (model.set == Just ( n, n2 ))
                                ]
                                { onPress =
                                    if model.wallet == Nothing then
                                        Nothing

                                    else
                                        Just <| ConfirmCol ( n, n2 )
                                , label = none
                                }
                         --)n n2 col
                        )
                    >> row []
            )
        --|> column [ width fill, height fill ]
        --|> el [ width <| px 350, centerX, height <| px 350, clip, scrollbars ]
        |> column
            [ width fill
            , height fill

            --, el
            --[ width fill
            --, height fill
            --, Border.width 2
            --, Border.color white
            --]
            --none
            --|> inFront
            ]
        --|> column [ width fill, height fill, clip, scrollbars ]
        |> el
            [ centerX
            , cappedWidth 800
            , cappedHeight 800
            , clip
            , scrollbars
            , Border.glow white 1
            , fadeIn
            ]


viewSelect model =
    model.set
        |> unwrap
            (text ("Select a square to edit " ++ point model.wide)
                |> el
                    [ Background.color grey
                    , padding 10
                    , centerX
                    , Font.size
                        (if model.wide then
                            25

                         else
                            17
                        )
                    ]
            )
            (\( x, y ) ->
                let
                    selector =
                        Html.input
                            [ Html.Attributes.type_ "color"
                            , model.color.hex
                                |> Html.Attributes.value
                            , Html.Events.onInput
                                (\hex ->
                                    hex
                                        |> fromHex
                                        |> Maybe.map (\col -> { color = col, hex = hex })
                                        |> SelectCol
                                )
                            ]
                            []
                            |> Element.html
                            |> el []
                in
                [ [ [ text "Selected:"
                        |> el [ Font.size 25 ]
                    , [ "("
                      , String.fromInt (x + 1)
                      , ","
                      , String.fromInt (y + 1)
                      , ")"
                      ]
                        |> String.concat
                        |> text
                        |> el [ Font.bold, Font.size 25 ]
                    ]
                        |> row [ spacing 5 ]

                  --, selector
                  ]
                    |> column [ spacing 10, centerX ]
                , let
                    bx col =
                        Input.button
                            [ width <| px 30
                            , height <| px 30
                            , Background.color col
                            , Border.width 1
                            , Html.Attributes.title
                                (toHex col
                                    --++ " / "
                                    ++ " "
                                    ++ (col
                                            |> Element.toRgb
                                            |> (\{ red, green, blue } ->
                                                    "rgb("
                                                        ++ ([ red * 255, green * 255, blue * 255 ]
                                                                |> List.map (round >> String.fromInt)
                                                                |> String.join ", "
                                                           )
                                                        ++ ")"
                                               )
                                       )
                                )
                                |> htmlAttribute
                            ]
                            { onPress =
                                { hex = toHex col
                                , color = col
                                }
                                    |> Just
                                    |> SelectCol
                                    |> Just
                            , label = none
                            }
                  in
                  [ bx
                        (model.sqs
                            |> Array.get x
                            |> Maybe.andThen (Array.get y)
                            |> Maybe.withDefault grey
                        )
                  , text "➡"
                        |> el [ Font.size 25 ]

                  --, bx model.color.color
                  , selector
                  ]
                    |> row [ centerX, spacing 20 ]

                --, text model.color.hex
                , btn "Submit" Submit
                    |> el [ centerX ]
                ]
                    |> column
                        [ spacing 20
                        , padding 10
                        , centerX

                        --, width <| px 200
                        , cappedWidth 800
                        , Background.color white
                        , Background.color grey
                        ]
            )


fadeIn : Attribute msg
fadeIn =
    style "animation" "fadeIn 1s"


para txt =
    [ text txt ]
        |> paragraph []


point wide =
    if wide then
        "👉"

    else
        "☝️"
