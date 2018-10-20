
import Test.Hspec
import Network.N2O.Internal
import Data.BERT

main :: IO ()
main = do
  (t1, t2, _, _) <- runProto NilTerm undefined undefined protos
  hspec $ do
    describe "nop reply test" $ do
      it "test1" $ do
        t1 `shouldBe` reply
      it "test2" $ do
        t2 `shouldBe` (TupleTerm [binary, NilTerm])
  let proto1 = AtomTerm "proto1"
  (t1, t2, _, _) <- runProto proto1 undefined undefined protos
  hspec $ do
    describe "proto1 reply test" $ do
      it "test1" $ do
        t1 `shouldBe` reply
      it "test2" $ do
        t2 `shouldBe` proto1
  let proto2 = AtomTerm "proto2"
  (t1, t2, _, _) <- runProto proto2 undefined undefined protos
  hspec $ do
    describe "proto2 reply test" $ do
      it "test1" $ do
        t1 `shouldBe` reply
      it "test2" $ do
        t2 `shouldBe` proto2

data Proto1 = Proto1
instance N2OProto Proto1 where
  info _ p1@(AtomTerm "proto1") req state = return (reply, p1, req, state)
  info _ msg req state = return (unknown, msg, req, state)
data Proto2 = Proto2
instance N2OProto Proto2 where
  info _ p2@(AtomTerm "proto2") req state = return (reply, p2, req, state)
  info _ msg req state = return (unknown, msg, req, state)

protos :: [ProtoBox]
protos = [ProtoBox Proto1, ProtoBox Proto2]
