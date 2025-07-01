module Main where


import           Control.Concurrent             ( threadDelay )
import           Control.Monad                  ( forM_ )
import           Data.Maybe                     ( catMaybes )
import           System.Directory               ( doesFileExist )
import           System.Process                 ( CreateProcess
                                                , createProcess
                                                , proc
                                                , waitForProcess
                                                )
import           Text.Parsec                    ( alphaNum
                                                , char
                                                , choice
                                                , digit
                                                , endOfLine
                                                , many
                                                , many1
                                                , oneOf
                                                , optional
                                                , runParser
                                                , space
                                                , string
                                                , try, (<|>)
                                                )
import           Text.Parsec.String             ( Parser )


data FileTrim = FileTrim
  { inputFileName :: String
  , suffixTrims   :: [SuffixTrim]
  }
  deriving Show
data SuffixTrim = SuffixTrim
  { suffixName   :: String
  , quartetSpans :: [QuartetSpan]
  }
  deriving Show
data QuartetSpan = QuartetSpan
  { quartetName    :: String
  , startTimestamp :: String
  , stopTimestamp  :: String
  }
  deriving Show

parseFileTrim :: Parser [FileTrim]
parseFileTrim = many1
  (FileTrim <$> parseInputFileName <*> many1 (try parseSuffixTrim) <* many space
  )

parseSuffixTrim :: Parser SuffixTrim
parseSuffixTrim = SuffixTrim <$> parseSuffix <*> many1 (try parseQuartetSpan)

parseQuartetSpan :: Parser QuartetSpan
parseQuartetSpan =
  QuartetSpan
    <$> (many1 (try alphaNum <|> char '_' <|> char '-') <* many1 space)
    <*> (sequence [digit, digit, char ':', digit, digit, char ':', digit, digit]
        <* many1 space
        )
    <*> (sequence [digit, digit, char ':', digit, digit, char ':', digit, digit]
        <* many space
        )

parseSuffix :: Parser String
parseSuffix = many1 (try alphaNum <|> char '_' <|> char '-') <* many space

parseInputFileName :: Parser String
parseInputFileName =
  string ">"
    *> many1 space
    *> many1 (choice [alphaNum, oneOf ['-', '_', '.', '/']])
    <* many space


getRunTrimProcess
  :: String -> String -> String -> String -> String -> IO (Maybe CreateProcess)
getRunTrimProcess inp suff qName sTime eTime =
  let
    outFileName = qName ++ "_" ++ suff ++ ".mp4"
    command = "ffmpeg"
    args = ["-ss", sTime, "-to", eTime, "-i", inp, "-c:v", "copy", outFileName]
  in
    do
      b <- doesFileExist outFileName
      return $ if b then Nothing else Just (proc command args)

getRunTrimProcessCompressed
  :: String -> String -> String -> String -> String -> IO (Maybe CreateProcess)
getRunTrimProcessCompressed inp suff qName sTime eTime =
  let outFileName = qName ++ "_" ++ suff ++ "_compressed.mp4"
      command     = "ffmpeg"
      args =
        [ "-ss"
        , sTime
        , "-to"
        , eTime
        , "-i"
        , inp
        , "-vf"
        , "scale=w=1280:h=720"
        , "-crf"
        , "30"
        , "-c:v"
        , "libx264"
        , outFileName
        ]
  in  do
        b <- doesFileExist outFileName
        return $ if b then Nothing else Just (proc command args)


getRunTrimProcesses :: FileTrim -> IO [CreateProcess]
getRunTrimProcesses (FileTrim inputFileName sts) = do
  ps <-
    concat
      <$> mapM
            (\(SuffixTrim suffixName quartetSpans) -> mapM
              (\(QuartetSpan quartetName startTimestamp stopTimestamp) ->
                getRunTrimProcess inputFileName
                                  suffixName
                                  quartetName
                                  startTimestamp
                                  stopTimestamp
              )
              quartetSpans
            )
            sts
  return $ catMaybes ps


getRunTrimProcessesCompressed :: FileTrim -> IO [CreateProcess]
getRunTrimProcessesCompressed (FileTrim inputFileName sts) = do
  ps <-
    concat
      <$> mapM
            (\(SuffixTrim suffixName quartetSpans) -> mapM
              (\(QuartetSpan quartetName startTimestamp stopTimestamp) ->
                getRunTrimProcessCompressed inputFileName
                                            suffixName
                                            quartetName
                                            startTimestamp
                                            stopTimestamp
              )
              quartetSpans
            )
            sts
  return $ catMaybes ps


runProcessAndWait :: CreateProcess -> IO ()
runProcessAndWait cp = do
  (_, _, _, h) <- createProcess cp
  _            <- waitForProcess h
  threadDelay (2 * 1000000)
  return ()

main :: IO ()
main = do
  txt <- readFile "timestamps.txt"
  let res = runParser parseFileTrim () "barbershopTrimmer" txt
  case res of
    (Left  e    ) -> print e
    (Right reses) -> forM_ reses $ \res -> do
      mProcs  <- getRunTrimProcesses res
      -- let mProcs = []
      mCProcs <- return []-- getRunTrimProcessesCompressed res
      let mProcsFinal = mProcs ++ mCProcs
      print res
      mapM_ runProcessAndWait mProcsFinal
