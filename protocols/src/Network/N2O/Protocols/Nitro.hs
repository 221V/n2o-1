{-# LANGUAGE ScopedTypeVariables #-}
module Network.N2O.Protocols.Nitro where

import Control.Monad (forM_)
import qualified Data.Map.Strict as M
import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString as BS
import qualified Data.Binary as B
import qualified Data.ByteString.Lazy.Char8 as CL8
import Data.IORef
import Network.N2O.Core
import Network.N2O.Types
import Network.N2O.Nitro
import Network.N2O.Protocols.Types

nitroProto :: (Show a, B.Binary a) => Proto N2OProto a L.ByteString
nitroProto = Proto { protoInfo = nitroInfo }

nitroInfo :: forall a. (Show a, B.Binary a) => N2OProto a -> N2O N2OProto a L.ByteString Return
nitroInfo message = do
  ref <- ask
  cx@Cx {cxHandler = handle, cxEncoder = encode, cxDePickle = dePickle} <- lift $ readIORef ref
  lift $ putStrLn ("NITRO : " ++ show message)
  case message of
    msg@(N2ONitro (I pid)) -> do
      handle Init
      actions <- getActions
      Reply . encode <$> renderActions' actions
    msg@(N2ONitro (P _source pickled linked)) -> do
      forM_ (M.toList linked) (uncurry put)
      case dePickle pickled of
        Just x -> do
          handle (Message x)
          actions <- getActions
          Reply . encode <$> renderActions' actions
        _ -> return Unknown
  where
    renderActions' actions =
      case actions of
        [] -> return L.empty
        actions -> do
          putActions []
          first <- renderActions actions
          actions2 <- getActions
          second <- renderActions actions2
          putActions []
          return $ first <> CL8.pack ";" <> second
