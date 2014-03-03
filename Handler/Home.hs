{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Home where

import Import
-- we import Yesod.Auth(maybeAuthId) because it doesn't seem to like being imported 
-- from the Import.hs file and we need it to display or hide the snip creation form 
-- in the Snips handler  
import Yesod.Auth (maybeAuthId,Route (LoginR))

-- For now just redirect the homepage. TODO make a nice homepage
getHomeR :: Handler Html
getHomeR = do
        redirect $ SnipsR 

-- The about page, pretty boring. 
getAboutR :: Handler Html
getAboutR = do
    defaultLayout $ do
        setTitle "Snipp.IO: A pastebin sort of thingy"
        $(widgetFile "about")


-- The form for inputting new snips. This is more interesting and 
-- shows the more complex FieldSettings way of implementing applicative
-- form fields. We'd normally write areq textField "Title" Nothing, but
-- easier CLI interaction
snipForm :: Form (Snip)
snipForm = renderBootstrap $ Snip
  <$> areq textField "Title" { fsName = Just "t" } Nothing
  <*> areq textareaField "Content" {fsName = Just "c"} Nothing 
  <*> lift (liftIO getCurrentTime)  -- the "created at" datestamp


-- This is run when we receive a GET request for the snips page. 
-- Show the snipForm, and the most recent 10 snips
getSnipsR :: Handler Html
getSnipsR   = do
  muser <- maybeAuthId
  snips <- runDB $ selectList [] [LimitTo 10, Desc SnipCreated]
  (formWidget, enctype) <- generateFormPost snipForm
  defaultLayout $ do 
    setTitle "Snipp.IO: A pastebin sort of thingy"
    $(widgetFile "snips")



-- The web based implementation of the form handling-code
-- invoken when we make a POST request from the web. 
-- This won't work from the CLI as we receive a token id with 
-- the form. 
postSnipsR :: Handler ()
postSnipsR  = do
  ((result, _), _) <- runFormPost snipForm
  (_) <- case result of 
      FormSuccess snip -> do
        snipId <- runDB $ insert snip
        setMessage "Snip imported"
        redirect $ SnipR snipId
      _ -> do
        setMessage "Bad input of some description" 
        redirect SnipsR
  return ()

-- Show a single snip from a GET request giving that snip's id
-- or a 404 if the db doesn't hold the snip.
getSnipR :: Key Snip -> Handler Html
getSnipR snipid = do
  snip <- runDB $ get404 snipid
  defaultLayout $ do
    setTitle "Viewing snip"
    $(widgetFile "snip")

-- Respond to CLI POST requests. Note that we use runFormPostNoToken
-- meaning that we can accept input from places other than our form
postSnipsPlainR :: Handler ()
postSnipsPlainR  = do
  k <- lookupPostParam("k"::Text)
  key <- runDB $ count [UserApikey ==. k]
  if (key < 1) 
    then do
      forbiddenPlain
      return ()
    else do
      ((result, _), _) <- runFormPostNoToken snipForm
      (_) <- case result of 
          FormSuccess snip -> do
            snipId <- runDB $ insert snip
            redirect $ SnipPlainR snipId
          _ -> do
            setMessage "Bad input of some description" 
            redirect SnipsR
      return ()

-- Prints out the proper URL for the snip. Intended to be called when 
-- creating snips from the CLI. Because you don't necessarily want
-- to see everything in your terminal straight away. 
getSnipPlainR :: Key Snip -> Handler Html
getSnipPlainR snipid = do
  (_) <- runDB $ get404 snipid
  giveUrlRenderer [hamlet|
    @{SnipR snipid} 
    \#
  |] -- \# gives us a trailing newline. 

cliUsage :: Widget 
cliUsage = $(widgetFile "cliUsage")
