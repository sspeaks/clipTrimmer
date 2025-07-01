module Main where
-- #! /usr/bin/env nix-shell
-- #! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: with ps; [base])"

import Data.Char (isSpace)
import System.IO
import System.Exit
import Control.Monad
import System.Directory

startingChars :: String -> Int
startingChars [] = 0
startingChars (x:xs)
    | (not . isSpace) x = 1 + startingChars xs
    | otherwise  = 0

morphLine :: String -> Int -> String
morphLine a v = start ++ (replicate shorterLen ' ') ++ end'
    where 
        (start,end) = break isSpace a
        end' = dropWhile isSpace end
        shorterLen = v - (length start) + 1
          

main :: IO ()
main = do
    doesFileExist "timestamps.txt" >>= \exists -> when (not exists) (putStrLn "Nothing to pad... timestamps.txt doesn't exit" >> exitFailure)
    h <- openFile "timestamps.txt" ReadWriteMode
    f <- hGetContents' h
    let !ls = lines f
    let maxLen = maximum $ (map startingChars ls)
    let newLines = map (flip morphLine maxLen) ls
    let newF = unlines newLines
    writeFile "timestamps.txt" newF
    
