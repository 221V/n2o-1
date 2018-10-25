{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Network.N2O
import Network.N2O.Util
import Data.BERT
import qualified Data.Binary as B
import qualified Data.ByteString.Lazy as BS

-- | Define incoming event data type instead of dealing with Erlang @Term@s
data Evt = Init | Terminate | Greet BS.ByteString deriving Show

-- | Message decoder
decoder msg@(MsgBin bin) =
  case (dec bertCodec) msg of
    Just (TupleTerm [AtomTerm "client", TupleTerm [AtomTerm "greet", BytelistTerm name]]) -> Just $ Greet name
    _ -> Nothing
decoder (MsgTxt "N2OInit") = Just Init
decoder (MsgTxt "N2OTerminate") = Just Terminate
-- | Message encoder
encoder bs = MsgBin $ B.encode (TupleTerm [AtomTerm "io", BytelistTerm bs, NilTerm]) -- reply with IO message

initCx = mkCx
  { cxHandlers = [router]
  , cxProtos = [proto1]
  , cxCodec = Codec { enc = encoder, dec = decoder }}
main = runServer "localhost" 3000 initCx

router :: Cx Evt BS.ByteString -> Cx Evt BS.ByteString
router cx = cx{ cxEvHnd = event } -- we have single (index) page only

-- | Here's our event handler
event :: Evt -> IO BS.ByteString

event Init = do
  return "qi('system').innerText='What is your name?'"

event (Greet name) = do
    return $ "qi('system').innerText='Hello, " <> (jsEscape name) <> "!'"

-- | -----------------------------

proto1 :: Proto Evt BS.ByteString
proto1 = Proto
  { protoInit = return ()
  , protoInfo = \msg cx@Cx{cxEvHnd=handle} -> do
      let (Codec{enc=enc,dec=dec}) = cxCodec cx
          evt = dec msg
      case evt of
        Just e -> do
          rep <- handle e
          return (Rslt Reply (enc rep), cx)
        Nothing -> return (Rslt Unknown (MsgBin ""), cx)
  }
