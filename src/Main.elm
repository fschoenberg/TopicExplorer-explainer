module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, button, div, fieldset, figure, footer, h1, h2, header, i, iframe, img, input, label, li, nav, node, option, p, section, select, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (checked, class, coords, href, id, name, placeholder, shape, src, style, title, type_, usemap, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D
import List
import Markdown
import Maybe.Extra
import Pivot exposing (Pivot)
import String
import Svg
import Svg.Attributes as SvgAttr
import Svg.Events
import Url
import Url.Parser as Parser exposing ((</>), Parser)


main : Program () { page : SelectedPage, nlp : NLP, workflows : Dict String Workflow, modal : Maybe ( List ExplanationPart, VariableStore ), showString : String, key : Nav.Key, url : Url.Url } Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        cmdList =
            case url.fragment of
                Nothing ->
                    []

                Just fragment ->
                    []
    in
    ( { page = StartWorkflow
      , nlp = EnglishTreetagger
      , workflows = Dict.empty
      , modal = Nothing
      , showString = ""
      , key = key
      , url = url
      }
    , Cmd.batch (getForward :: cmdList)
    )


getForward : Cmd Msg
getForward =
    Http.get
        { url = "/forward-to-workflows.json"
        , expect = Http.expectJson GotForward forwardUrlDecoder
        }


forwardUrlDecoder : D.Decoder String
forwardUrlDecoder =
    D.field "forward-to"
        D.string


getWorkflows : String -> Cmd Msg
getWorkflows workflowUrl =
    Http.get
        { url = workflowUrl
        , expect = Http.expectJson GotWorkflows workflowDecoder
        }


workflowDecoder : D.Decoder (Dict String Workflow)
workflowDecoder =
    D.dict
        (D.map2 Workflow
            (D.field "variables"
                (D.dict (D.nullable D.string))
            )
            (D.field "steps"
                (D.oneOrMore Pivot.fromCons
                    (D.map4
                        StepContent
                        (D.field "title" D.string)
                        (D.field "explanation"
                            (D.list
                                (D.oneOf
                                    [ D.map ExplanationMarkDown
                                        (D.field "markdown" D.string)
                                    , D.map InputParameter
                                        (D.field "input-parameter" D.string)
                                    ]
                                )
                            )
                        )
                        (D.maybe
                            (D.field "application" D.string
                                |> D.andThen
                                    (\s ->
                                        case s of
                                            "Adminer" ->
                                                D.succeed Adminer

                                            "Jobson" ->
                                                D.succeed Jobson

                                            _ ->
                                                D.fail <| "Workflow step contains an unsupported application"
                                    )
                            )
                        )
                        (D.maybe
                            (D.field "url"
                                (D.list
                                    (D.oneOf
                                        [ D.map UrlPiece
                                            (D.field "url-piece" D.string)
                                        , D.map UrlParameterPiece
                                            (D.field "url-parameter-piece" D.string)
                                        ]
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias VariableStore =
    Dict String (Maybe String)


type alias Workflow =
    { variables : VariableStore
    , pages : Pivot StepContent
    }


type alias Model =
    { page : SelectedPage
    , nlp : NLP
    , workflows : Dict String Workflow
    , modal : Maybe ( List ExplanationPart, VariableStore )
    , showString : String
    , key : Nav.Key
    , url : Url.Url
    }


type alias StepContent =
    { title : String
    , explanation : List ExplanationPart
    , page : Maybe SelectedPage
    , url : Maybe (List UrlPart)
    }


type ExplanationPart
    = ExplanationMarkDown String
    | InputParameter String
    | OutputParameter String


type UrlPart
    = UrlPiece String
    | UrlParameterPiece String


type NLP
    = EnglishTreetagger
    | GermanTreetagger
    | JapaneseMecab


type SelectedPage
    = Adminer
    | Creator
    | Jobson
    | StartWorkflow
    | WorkflowPage String


type Msg
    = ChosePage SelectedPage
    | ChoseNlp NLP
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ModifyWorkflow WfMsg
    | OpenModal ( List ExplanationPart, VariableStore )
    | CloseModal
    | GotWorkflows (Result Http.Error (Dict String Workflow))
    | GotForward (Result Http.Error String)


type WfMsg
    = Next String
    | Previous String
    | Reset String
    | UpdateParameter String String String


errorToString error =
    case error of
        Http.BadUrl s ->
            "BadUrl " ++ s

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus i ->
            "BadStatus " ++ String.fromInt i

        Http.BadBody s ->
            "BadBody " ++ s


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenModal explanation ->
            ( { model | modal = Just explanation }, Cmd.none )

        CloseModal ->
            ( { model | modal = Nothing }, Cmd.none )

        ChosePage newPage ->
            ( { model | page = newPage }, Cmd.none )

        ChoseNlp newNlp ->
            ( { model | nlp = newNlp }, Cmd.none )

        GotWorkflows (Ok newWorkflows) ->
            ( { model | workflows = newWorkflows }, Cmd.none )

        GotWorkflows (Err error) ->
            ( { model | showString = errorToString error }
            , Cmd.none
            )

        GotForward (Ok workflowUrl) ->
            ( model, getWorkflows workflowUrl )

        GotForward (Err error) ->
            ( { model | showString = errorToString error }
            , Cmd.none
            )

        ModifyWorkflow wfMsg ->
            ( { model
                | workflows = updateWorkflow model.workflows wfMsg
                , page =
                    let
                        isReset x =
                            case x of
                                Reset _ ->
                                    True

                                _ ->
                                    False
                    in
                    if wfMsg |> isReset then
                        StartWorkflow

                    else
                        model.page
              }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just fragment ->
                            ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    --            ( model, Cmd.none )
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                cmdList =
                    case url.fragment of
                        Nothing ->
                            []

                        Just fragment ->
                            []
            in
            ( { model | url = url }
            , Cmd.batch cmdList
            )


updateWorkflow : Dict String Workflow -> WfMsg -> Dict String Workflow
updateWorkflow workflows wfMsg =
    let
        changeWorkflow :
            String
            -> (Pivot StepContent -> Maybe (Pivot StepContent))
            -> Dict String Workflow
        changeWorkflow w op =
            let
                updateOp :
                    Maybe Workflow
                    -> Maybe Workflow
                updateOp =
                    Maybe.andThen (\{ variables, pages } -> Pivot.withRollback op pages |> (\x -> Just (Workflow variables x)))
            in
            Dict.update w updateOp workflows
    in
    case wfMsg of
        Next wfTitle ->
            changeWorkflow wfTitle Pivot.goR

        Previous wfTitle ->
            changeWorkflow wfTitle Pivot.goL

        Reset wfTitle ->
            changeWorkflow wfTitle (Pivot.goTo 0)
                |> Dict.update wfTitle (Maybe.map (\{ variables, pages } -> Workflow Dict.empty pages))

        UpdateParameter wfTitle name newValue ->
            Dict.update wfTitle
                (Maybe.map
                    (\{ variables, pages } ->
                        Workflow
                            (Dict.update
                                name
                                (\v -> Just (Just newValue))
                                variables
                            )
                            pages
                    )
                )
                workflows


view : Model -> Browser.Document Msg
view model =
    let
        navbarHtml =
            navbar model

        workflowListHtml =
            viewWorkflow model

        ifConfig =
            iFrameConfig model

        html =
            [ section [ class "hero is-fullheight has-background-white" ]
                [ applicationHeader navbarHtml workflowListHtml
                , iframeSection ifConfig
                ]
            ]
    in
    Browser.Document applicationTitle html


applicationTitle : String.String
applicationTitle =
    "TopicExplorer"


applicationHeader : Html Msg -> Maybe (Html Msg) -> Html Msg
applicationHeader navbarHtml workflowPage =
    div [ class "hero-head" ] <|
        [ div [ class "container" ]
            [ h1 [ class "title" ]
                [ text applicationTitle ]
            ]
        , navbarHtml
        ]
            ++ Maybe.Extra.toList workflowPage


navbar : Model -> Html Msg
navbar model =
    let
        isActive : Bool -> String
        isActive active =
            if active then
                " is-active"

            else
                ""
    in
    nav
        [ class "navbar has-background-white"
        , role "navigation"
        , ariaLabel "main navigation"
        ]
        [ div [ class "container" ]
            [ div [ class "navbar-brand" ]
                [ a
                    [ role "button"
                    , class "navbar-burger burger"
                    , ariaLabel "menu"
                    , ariaExpanded "false"
                    , dataTarget "navbarBasicExample"
                    ]
                    [ span [ ariaHidden "true" ] []
                    , span [ ariaHidden "true" ] []
                    , span [ ariaHidden "true" ] []
                    ]
                ]
            , div
                [ id "navbarBasicExample"
                , class "navbar-menu"
                ]
                [ div [ class "navbar-start" ]
                    [ div [ class "control  navbar-item" ]
                        [ div [ class "select" ]
                            [ select [ class "is-hovered" ]
                                [ option [ onClick <| ChoseNlp EnglishTreetagger ] [ text "English Treetagger" ]
                                , option [ onClick <| ChoseNlp GermanTreetagger ] [ text "German Treetagger" ]
                                , option [ onClick <| ChoseNlp JapaneseMecab ] [ text "Japanese Mecab" ]
                                ]
                            ]
                        ]
                    , a [ class ("navbar-item is-tab" ++ isActive (model.page == StartWorkflow)), onClick (ChosePage StartWorkflow), href "" ] [ text "Workflow" ]
                    , a [ class ("navbar-item is-tab" ++ isActive (model.page == Creator)), onClick (ChosePage Creator), href "" ] [ text "Creator" ]
                    , a [ class ("navbar-item is-tab" ++ isActive (model.page == Adminer)), onClick (ChosePage Adminer), href "" ] [ text "Database" ]
                    , a [ class ("navbar-item is-tab" ++ isActive (model.page == Jobson)), onClick (ChosePage Jobson), href "" ] [ text "Jobson" ]
                    ]
                ]
            ]
        ]


viewExplanationPart : String -> VariableStore -> ExplanationPart -> Html Msg
viewExplanationPart wf varStore e =
    case e of
        ExplanationMarkDown mdString ->
            div [ class "content has-text-left" ] [ Markdown.toHtml [] mdString ]

        InputParameter name ->
            let
                valueAttr =
                    Dict.get name varStore
                        |> Maybe.Extra.join
                        |> (\valueMaybe ->
                                case valueMaybe of
                                    Just val ->
                                        [ value val ]

                                    Nothing ->
                                        []
                           )
            in
            div [ class "field" ]
                [ label [ class "label" ] [ text name ]
                , div [ class "control" ]
                    [ input
                        ([ class "input"
                         , type_ "text"
                         , placeholder name
                         , onInput (\newValue -> ModifyWorkflow (UpdateParameter wf name newValue))
                         ]
                            ++ valueAttr
                        )
                        []
                    ]
                ]

        OutputParameter string ->
            div [] []


viewExplanationParts : String -> Maybe VariableStore -> Maybe (List ExplanationPart) -> List (Html Msg)
viewExplanationParts wf varStore list =
    Maybe.map2 (\v l -> List.map (viewExplanationPart wf v) l) varStore list
        |> Maybe.withDefault []


viewWorkflow : Model -> Maybe (Html Msg)
viewWorkflow model =
    let
        viewWorkflowControls : String -> VariableStore -> Int -> Int -> Bool -> StepContent -> Html Msg
        viewWorkflowControls wp variables currentStepNo totalStepNo hasNext stepContent =
            let
                ( nextMsg, nextText ) =
                    if hasNext then
                        ( ModifyWorkflow <| Next wp, "Next" )

                    else
                        ( ModifyWorkflow <| Reset wp, "Finish" )
            in
            div [ class "level is-mobile container" ]
                [ div [ class "level-left" ]
                    [ div [ class "level-item has-text-centered" ]
                        [ div []
                            [ a [ href "#", class "button  is-success", onClick (ModifyWorkflow <| Previous wp) ] [ text "Previous" ]
                            ]
                        ]
                    ]
                , div [ class "level-item has-text-centered" ]
                    [ div [ class "level" ]
                        ([ div [ class "level-item" ]
                            [ text stepContent.title ]
                         ]
                            ++ (case stepContent.page of
                                    Just _ ->
                                        [ div [ class "level-item" ]
                                            [ a [ class "button is-small is-info", href "#", onClick (OpenModal ( stepContent.explanation, variables )) ] [ text "Detailed Explanation" ]
                                            , div
                                                [ class
                                                    ("modal "
                                                        ++ (if Maybe.Extra.isJust model.modal then
                                                                "is-active"

                                                            else
                                                                ""
                                                           )
                                                    )
                                                ]
                                                [ div [ class "modal-background", onClick CloseModal ] []
                                                , div [ class "modal-card" ]
                                                    [ header [ class "modal-card-head" ]
                                                        [ p [ class "modal-card-title" ]
                                                            [ text "Detailed Explanation" ]
                                                        , button [ class "delete", ariaLabel "close", onClick CloseModal ] []
                                                        ]
                                                    , section [ class "modal-card-body" ]
                                                        (( Maybe.map Tuple.first model.modal, Maybe.map Tuple.second model.modal )
                                                            |> (\( l, v ) -> viewExplanationParts wp v l)
                                                        )
                                                    , footer [ class "modal-card-foot" ]
                                                        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]

                                    Nothing ->
                                        []
                               )
                            ++ [ div [ class "level-item" ]
                                    [ span [ class "heading" ] [ text ("Step " ++ String.fromInt currentStepNo ++ "/" ++ String.fromInt totalStepNo) ]
                                    ]
                               ]
                        )
                    ]
                , div [ class "level-right" ]
                    [ div [ class "level-item has-text-centered" ]
                        [ div []
                            [ a [ href "#", class "button is-success", onClick nextMsg ] [ text nextText ]
                            ]
                        ]
                    ]
                ]

        viewWorkflowPage : String -> Dict String Workflow -> Maybe (Html Msg)
        viewWorkflowPage wp workflows =
            Dict.get wp workflows
                |> Maybe.map
                    (\{ variables, pages } ->
                        Pivot.getC pages
                            |> viewWorkflowControls wp variables (1 + Pivot.lengthL pages) (Pivot.lengthA pages) (Pivot.hasR pages)
                    )
    in
    case model.page of
        WorkflowPage wp ->
            viewWorkflowPage wp model.workflows

        _ ->
            Nothing


type alias IframeConfiguration =
    { creatorUrlSuffix : String
    , adminerUrlSuffix : String
    , creatorActive : Bool
    , adminerActive : Bool
    , jobsonActive : Bool
    , startWorkflowActive : Bool
    , workflowPageActive : Bool
    , workflowStepExplanation : Maybe (List ExplanationPart)
    , variables : Maybe VariableStore
    , workflow : Maybe String
    , workflowNames : List String
    }


iFrameConfig : Model -> IframeConfiguration
iFrameConfig model =
    let
        creatorUrlSuffix =
            case model.nlp of
                EnglishTreetagger ->
                    "/creator/en/treetagger/"

                GermanTreetagger ->
                    "/creator/de/treetagger/"

                JapaneseMecab ->
                    "/creator/jp/mecab/"

        adminerUrlSuffix =
            let
                urlSuffix =
                    case model.page of
                        WorkflowPage workflowKey ->
                            let
                                workflow =
                                    Dict.get workflowKey model.workflows
                            in
                            workflow
                                |> Maybe.map
                                    (\w ->
                                        let
                                            currentStepContent : StepContent
                                            currentStepContent =
                                                Pivot.getC w.pages

                                            currentVariables : VariableStore
                                            currentVariables =
                                                w.variables
                                        in
                                        if currentStepContent.page == Just Adminer then
                                            currentStepContent.url
                                                |> Maybe.map
                                                    (\urlParts ->
                                                        List.map
                                                            (\urlPart ->
                                                                case urlPart of
                                                                    UrlPiece x ->
                                                                        x

                                                                    UrlParameterPiece x ->
                                                                        Dict.get x w.variables
                                                                            |> Maybe.Extra.join
                                                                            |> Maybe.withDefault ""
                                                            )
                                                            urlParts
                                                            |> String.join ""
                                                    )
                                                |> Maybe.withDefault ""

                                        else
                                            ""
                                    )
                                |> Maybe.withDefault ""

                        _ ->
                            ""
            in
            (case model.nlp of
                EnglishTreetagger ->
                    "/?server=topicexplorer-db&username=root&db=TE_MANAGEMENT_EN_TREETAGGER"

                GermanTreetagger ->
                    "/?server=topicexplorer-db&username=root&db=TE_MANAGEMENT_DE_TREETAGGER"

                JapaneseMecab ->
                    "/?server=topicexplorer-db&username=root&db=TE_MANAGEMENT_JP_MECAB"
            )
                ++ urlSuffix

        isWorkflowPage : SelectedPage -> Bool
        isWorkflowPage p =
            case p of
                WorkflowPage _ ->
                    True

                _ ->
                    False

        --(stepContent, variables) : (Maybe StepContent, Maybe VariableStore)
        ( stepContent, variables, wf ) =
            case model.page of
                WorkflowPage wp ->
                    Dict.get wp model.workflows
                        |> (\workflow -> ( workflow |> Maybe.map (.pages >> Pivot.getC), workflow |> Maybe.map .variables, Just wp ))

                _ ->
                    ( Nothing, Nothing, Nothing )

        stepContentPageEquals : SelectedPage -> Bool
        stepContentPageEquals x =
            stepContent
                |> Maybe.map
                    (\y ->
                        case y.page of
                            Just z ->
                                z == x

                            Nothing ->
                                False
                    )
                |> Maybe.withDefault False
    in
    IframeConfiguration
        creatorUrlSuffix
        adminerUrlSuffix
        (model.page == Creator || stepContentPageEquals Creator)
        (model.page == Adminer || stepContentPageEquals Adminer)
        (model.page == Jobson || stepContentPageEquals Jobson)
        (model.page == StartWorkflow || stepContentPageEquals StartWorkflow)
        (isWorkflowPage model.page)
        (stepContent
            |> Maybe.andThen
                (\s ->
                    case s.page of
                        Just _ ->
                            Nothing

                        Nothing ->
                            Just s.explanation
                )
        )
        (stepContent
            |> Maybe.andThen
                (\s ->
                    case s.page of
                        Just _ ->
                            Nothing

                        Nothing ->
                            variables
                )
        )
        (stepContent
            |> Maybe.andThen
                (\s ->
                    case s.page of
                        Just _ ->
                            Nothing

                        Nothing ->
                            wf
                )
        )
        (Dict.keys model.workflows)


iframeSection : IframeConfiguration -> Html Msg
iframeSection ifConfig =
    makeHeroBodyWithTiles
        [ makeTileChild (Maybe.Extra.isJust ifConfig.workflowStepExplanation)
            (viewExplanationParts (Maybe.withDefault "" ifConfig.workflow) ifConfig.variables ifConfig.workflowStepExplanation)
        , makeTileChild ifConfig.startWorkflowActive
            [ div []
                [ text "Start an Workflow."
                , ul [] <| List.map (\w -> li [] [ a [ href "#", onClick (ChosePage <| WorkflowPage w) ] [ text w ] ]) ifConfig.workflowNames
                ]
            ]
        , makeTileChild ifConfig.creatorActive
            [ makeIframe
                ("http://localhost:8001/" ++ ifConfig.creatorUrlSuffix)
                "Creator"
            ]
        , makeTileChild ifConfig.adminerActive
            [ makeIframe
                ("http://localhost:8002" ++ ifConfig.adminerUrlSuffix)
                "Adminer"
            ]
        , makeTileChild ifConfig.jobsonActive
            [ makeIframe
                "http://localhost:8001/jobson/#/submit"
                "Jobson"
            ]
        ]


makeHeroBodyWithTiles : List (Html Msg) -> Html Msg
makeHeroBodyWithTiles tileChilds =
    section [ class "hero-body", Html.Attributes.attribute "height" "100%", Html.Attributes.attribute "style" "height:100%" ]
        [ div [ class "container", Html.Attributes.attribute "height" "100%", Html.Attributes.attribute "style" "height:100%" ]
            [ div [ class "tile is-ancestor", Html.Attributes.attribute "height" "100%", Html.Attributes.attribute "style" "height:100%" ]
                [ div [ class "tile is-parent is-vertical", Html.Attributes.attribute "height" "100%", Html.Attributes.attribute "style" "height:100%" ]
                    tileChilds
                ]
            ]
        ]


makeTileChild : Bool -> List (Html Msg) -> Html Msg
makeTileChild childActivity childContent =
    let
        isActive : Bool -> String
        isActive active =
            if active then
                ""

            else
                "position:absolute;left:-5000px;"
    in
    div
        [ class "tile is-child box"
        , Html.Attributes.attribute "height" "100%"
        , Html.Attributes.attribute "style" (isActive childActivity ++ "height:100%")
        ]
        childContent


makeIframe : String -> String -> Html Msg
makeIframe url title =
    iframe
        [ Html.Attributes.attribute "scrolling" "yes"
        , Html.Attributes.attribute "src" url
        , Html.Attributes.attribute "title" title
        , Html.Attributes.attribute "frameborder" "1"
        , Html.Attributes.attribute "width" "100%"
        , Html.Attributes.attribute "height" "100%"
        , Html.Attributes.attribute "allowfullscreen" "true"
        , Html.Attributes.attribute "style" "height:100%"
        ]
        []


ariaLabel : String -> Attribute msg
ariaLabel value =
    Html.Attributes.attribute "aria-label" value


ariaHidden : String -> Attribute msg
ariaHidden value =
    Html.Attributes.attribute "aria-hidden" value


role : String -> Attribute msg
role value =
    Html.Attributes.attribute "role" value


ariaHaspopup : String -> Attribute msg
ariaHaspopup value =
    Html.Attributes.attribute "aria-haspopup" value


ariaControls : String -> Attribute msg
ariaControls value =
    Html.Attributes.attribute "aria-controls" value


ariaExpanded : String -> Attribute msg
ariaExpanded value =
    Html.Attributes.attribute "aria-expanded" value


dataTarget : String -> Attribute msg
dataTarget value =
    Html.Attributes.attribute "data-target" value
