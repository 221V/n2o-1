{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeFamilies      #-}

module Network.N2O.Nitro where

import           Data.BERT
import qualified Data.Binary                 as Bin
import qualified Data.ByteString             as BS
import           Data.ByteString.Base64.Lazy (decode, encode)
import qualified Data.ByteString.Lazy        as BL
import qualified Data.ByteString.Lazy.Char8  as C8
import           Data.Char                   (toLower)
import           Data.List                   (intersperse)
import           Data.String
import qualified Data.Text                   as T
import           Fmt
import           Fmt.Internal.Core
import           Prelude                     hiding (id)

instance IsString Term where
  fromString ""                  = NilTerm
  fromString ('b':'i':'n':':':s) = BinaryTerm $ C8.pack s
  fromString s                   = AtomTerm s

instance FromBuilder Term where
  fromBuilder t = AtomTerm $ fromBuilder t
instance Buildable Term where
  build (AtomTerm t) = build t

type Action = T.Text

data Element
  = Element { name      :: String
            , id        :: Term
            , body      :: [Element]
            , postback  :: Term
            , source    :: [Term]
            , noBody    :: Bool
            , noClosing :: Bool
            }
  | Text T.Text
  deriving (Show)

-- data EventType = Click deriving (Show)
data Event = Event
  { eventTarget   :: Term
  , eventPostback :: Term
  , eventType     :: Term
  , eventSource   :: [Term]
  } deriving (Show)

pickle :: Term -> String
pickle =  C8.unpack . encode . Bin.encode

depickle :: BL.ByteString -> Term
depickle b = case decode b of
  Left e   -> error e
  Right bs -> Bin.decode bs

-- Erlang N2O polymorphism of render function:
-- each record has 'module' field - it is the dispatch value
-- nitro:render/1 - this is interface
-- wf_render:render/1 - dispatcher
-- action_event:render_action/1 - implementation for events
-- format: {pickle,target,event,_,{name1,val1},{name2,val2}...}
renderEvent :: (Monad m) => Event -> m Action
renderEvent Event {..} =
  case eventSource of
    [] -> void
    src ->
      case eventPostback of
        "" -> void
        pb ->
          return $
            "{ var x=qi('" +| eventTarget |+ "'); x && x.addEventListener('"
            +| eventType |+ "',function(event){"
            +| (postbackString pb eventTarget $ dataString src) |+ "});};"
  where
    postbackString :: Term -> Term -> String -> String
    postbackString pb el dat =
      "{ if (validateSources(" +| terms2str eventSource |+
      ")) {ws.send(enc(tuple(atom('pickle'),bin('" +| el |+
      "'),bin('" +| pickle pb |+ "')," +| dat |+ "))); } else console.log('Validation Error'); }"
    dataString src =
      "[tuple(tuple(utf8_toByteArray('" +| eventTarget |+ "'),bin('detail')),[]),"
      +| (concat $ intersperse "," $ map renderSource src) |+ "]"
    renderSource s =
      "tuple(utf8_toByteArray('" +| s |+"'),querySource('" +| s |+"'))"
    terms2str [] = "[]"
    terms2str l =
      "[" ++
      (concat $
       intersperse "," $
       map
         (\t ->
            case t of
              AtomTerm a -> "'" ++ a ++ "'")
         l) ++
      "]"


renderElements :: Monad m => [Element] -> m Action
renderElements []     = return ""
renderElements (x:xs) = do
  y <- renderElement x
  ys <- renderElements xs
  return $ y <> ys

test :: IO ()
test = do
  x <- renderElement textbox{id="123"}
  y <- renderElement br
  print x
  print y

renderElement :: Monad m => Element -> m Action
renderElement (Text t) = return t
renderElement Element {..} = do
  case name of
    "br" -> return "<br>"
    _ -> do
      content <- renderElements body
      return $
        T.pack $
        if noBody
          then "<" +| name |+ " " +| idProp id |+ "/>"
          else "<" +| name |+ " " +| idProp id |+ ">" +| content |+ "</" +| name |+
               ">"
  where
    idProp :: Term -> String
    idProp x =
      if x == ""
        then ""
        else "id=\"" +| x |+ "\""

baseElement :: Element
baseElement =
  Element
    { id = ""
    , name = undefined
    , postback = ""
    , body = []
    , source = []
    , noBody = False
    , noClosing = False
    }

button :: Element
button = baseElement { name = "button"
                     , source = [] }

panel = baseElement { name = "div" }

text :: T.Text -> Element
text t = Text t

text' :: String -> Element
text' s = Text $ T.pack s

br = baseElement {name = "br", noBody = True, noClosing = True}

textbox :: Element
textbox = baseElement {name = "input type=\"text\"", noBody = True}

void :: Monad m => m Action
void = return "void(0);"

alert :: Monad m => T.Text -> m Action
alert s = return $ "alert('" <> s <> "');"

insertBottom :: Monad m => String -> Element -> m Action
insertBottom target elem = do
  content <- renderElement elem
  let
    tag = "div" :: String
    action =
        "(function(){ var div = qn('" +| tag |+ "'); div.innerHTML = '"
        +| content |+ "';qi('" +| target |+
        "').appendChild(div.firstChild); })();"
  return $ T.pack $ action

event =
  Event
    { eventTarget = ""
    , eventPostback = ""
    , eventType = undefined
    , eventSource = []
    }

click = event {eventType = "click"}
