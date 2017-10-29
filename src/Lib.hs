{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( someFunc
    ) where

import Network.SimpleIRC
import Data.Maybe
import qualified Data.ByteString.Char8 as B
import Data.Monoid
import Data.Foldable
import NLP.Hext.NaiveBayes
import Data.List
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE
import qualified Data.Text.Lazy as TL
import Control.Applicative
import Debug.Trace
import Control.Concurrent
import Control.Monad

onMessage :: BayesModel (Maybe T.Text) -> EventFunc
onMessage _ _ m | traceShow m False = undefined
onMessage _ s m | isNothing (mChan m) && mMsg m == "quit" && mNick m == Just "Gurkenglas" = disconnect s "quit"
onMessage model s m | mNick m /= Just "parrotbot" =
  for_ (traceShowId $ runBayes model $ traceShowId $ B.unpack $ mMsg m) $ \nick ->
    sendMsg s "#parrot" $ B.pack (T.unpack nick) <> ", " <> fromMaybe "a ghost" (mNick m) <> " on " <> fromMaybe "a private connection" (mChan m) <> " said " <> B.pack (show $  mMsg m) <> "."
onMessage _ _ _ = pure ()

f :: T.Text -> ([(T.Text, T.Text)], BayesModel (Maybe T.Text)) -> ([(T.Text, T.Text)], BayesModel (Maybe T.Text))
f line (replies, model) = case T.words line of
  bracketednick : msg@(punctuatedrepliee : _) -> let
    nick = fromJust $ T.stripPrefix "<" =<< T.stripSuffix ">" bracketednick
    mrepliee = T.stripSuffix "," punctuatedrepliee <|> T.stripSuffix ":" punctuatedrepliee
    mreplier = lookup nick replies
    in ( take 20 $ [(repliee, nick) | Just repliee <- [mrepliee]] ++ filter ((/=nick) . fst) replies
       , teach (TL.fromStrict $ T.unwords msg) mreplier model
       )
  _ -> (replies, model)

someFunc :: IO ()
someFunc = do
  model <- snd . foldr f ([], emptyModel) . T.lines . TE.decodeLatin1 <$> B.readFile "res/log"
  let events = [Privmsg $ onMessage model]
      freenode = (mkDefaultConfig "irc.freenode.net" "parrotbot")
            { cChannels = ["#parrot", "#haskell"] -- Channels to join on connect
            , cEvents   = events -- Events to bind
            }
  Right server <- connect freenode False True
  print =<< getChannels server
