{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Directory
import Data.Foldable
import Data.Char
import Control.Exception.Base
import qualified Data.ByteString.Char8 as B

main :: IO ()
main = B.writeFile "res/log" . B.unlines
  . filter (B.isInfixOf "Gurkenglas")
  . filter ((=="<") . B.take 1) . map (B.drop 9)
  . B.lines . B.concat
  =<< traverse (B.readFile . ("res/logs/"++)) . reverse =<< listDirectory "res/logs"
