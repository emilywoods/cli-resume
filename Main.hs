{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Data.Text as T
import qualified Graphics.Vty as V

import qualified Brick.Widgets.Dialog as D
import qualified Brick.Main as M
import Brick.Util (fg, on)
import qualified Brick.AttrMap as A
import Brick.Types
  ( Widget
  , BrickEvent(..)
  )
import Brick.Widgets.Core
  ( (<=>)
  , (<+>)
  , vLimit
  , vLimitPercent
  , hLimit
  , vBox
  , padAll
  , txt
  , str
  )

import qualified Brick.Types as T
import qualified Brick.Widgets.Center as C
import qualified Brick.Widgets.Border as B
import qualified Brick.Widgets.Border.Style as BS

data Choice = Home | About | Skills | Experience | Education | Projects | Objective 
          deriving (Show, Eq)

appEvent :: D.Dialog Choice -> BrickEvent () e -> T.EventM () (T.Next (D.Dialog Choice))
appEvent d (VtyEvent ev) =
    case ev of
        V.EvKey V.KEsc [] -> M.halt d
        V.EvKey (V.KChar 'q') [] -> M.halt d
        _ -> M.continue =<< D.handleDialogEvent ev d
appEvent d _ = M.continue d

theMap :: A.AttrMap
theMap = A.attrMap V.defAttr
    [ (D.buttonAttr, V.cyan `on` V.black)
    , (D.buttonSelectedAttr, V.brightMagenta `on` V.black)
    ]

-- Introduction

introduction :: Widget ()
introduction =
    C.center $
    txt $ "Welcome to Emily's resume!\n\nTo explore the different sections, click ← or →. To exit, click q or esc"

contactMe :: Widget ()
contactMe =
    B.borderWithLabel (str "How to reach me") $
    hLimit 50 $
    vLimit 8 $
    C.hCenter $
    txt $ "\n\n  Website: https://emilywoods.me  \n\n  Email: hello@emilywoods.me  \n\n  Github: emilywoods  \n\n"

aboutSection :: Widget ()
aboutSection =
    C.vCenter (str "Hello, my name is Emily 👋.\n\nI am an engineer, mostly of software these days.\n\nI started out as a Process Engineer, took a detour into Bioengineering\nand ended up in Software. Most recently, I am a backend developer and\ninfrastructure engineer.\n\nI also do technical writing and help organise PyLadies Berlin.\n\nMy non-coding hobbies include bumbling around bookstores,\ntrying to keep plants alive, sewing, and generally learning new things.📚 🌱")
    <=> contactMe

skillsSection :: Widget ()
skillsSection =
    C.center $
    txt $ "Skills, Interests, Volunteering."

workExperiences :: [T.Text]
workExperiences =
    [ "Jan 2018 - April 2020 Crate.io :: Engineer and SysAdmin\n\nCrate.io is the creator of CrateDB, CrateDB Cloud and Crate Analytics Plaform.\nI worked with Python, Kafka, CrateDB, Kubernetes, Azure, Terraform and Saltstack."
    , "September 2016 - December 2017 The App Business :: Backend Engineer.\n\nThe App Business works with organisations to build products which make the world better.\nI worked with Java, Ruby, Terraform and AWS and used Behavior and Test Driven Development"
    , "November 2013 - June 2015 PWF :: Operations Engineer.\n\nPWF is a manufacturer of concentrates.\nI managed capital expenditure and operations-based projects within the manufacturing plant."
    ]

experienceBlock :: T.Text -> Widget ()
experienceBlock experienceText =
    B.border $
    C.center $ padAll 1 $ txt $ "  " <> experienceText <> "  "

experienceSection :: Widget ()
experienceSection = 
    vBox $ experienceBlock <$> workExperiences

-- Education

educationSection :: Widget ()
educationSection =
    C.center $
    txt $ "2015-2016 :: MRes Bioengineering, Imperial College London\nThesis: Acoustic Particle Palpation for Tissue Elasticity Imaging\nGrade: Distinction\n\n2009 - 2013 :: BEng Process and Chemical Engineering, University College Cork\nGrade: 1.1\n\n "

-- Projects I've worked on

projectsSection :: Widget ()
projectsSection =
    C.center $
    padAll 10 $
    txt $ "look at what else i've made 👀"

-- Looking for

lookingForList :: [T.Text]
lookingForList =
    [ "◦ An asynchronous, remote-first environment"
    , "◦ To build technology that has a positive impact"
    , "◦ Interesting infrastructure and backend challenges"
    , "◦ Opportunities for technical writing"
    , "◦ An environment which values transparency and feedback"
    , "◦ A place which encourages learning, knowledge-sharing and mentorship"
    ]

lookingForBlock :: T.Text -> Widget ()
lookingForBlock lookingForText =
    C.center $ txt $ "  " <> lookingForText <> "  \n"

lookingForSection :: Widget ()
lookingForSection = vLimitPercent 95 $ vBox [ C.center $ vBox [ str "This is what I am looking for:\n\n"]
          , vLimitPercent 70 $ vBox $ lookingForBlock <$> lookingForList
          ]

selection :: D.Dialog Choice -> Widget ()  
selection d  
    | D.dialogSelection d == Just About = aboutSection
    | D.dialogSelection d == Just Skills = skillsSection
    | D.dialogSelection d == Just Experience = experienceSection
    | D.dialogSelection d == Just Education = educationSection
    | D.dialogSelection d == Just Projects = projectsSection
    | D.dialogSelection d == Just Objective = lookingForSection
    | otherwise   = introduction 

drawUI :: D.Dialog Choice -> [Widget ()]
drawUI d = [ui]
    where
        ui = D.renderDialog d $ C.hCenter $ padAll 1 $ str ""
            <=> selection d

initialState :: D.Dialog Choice
initialState = D.dialog (Just " ✨ Here I am ✨ ") (Just (0, choices)) 500
    where
        choices = [ ("Home", Home)
                  , ("About", About)
                  , ("Skills", Skills)
                  , ("Experience", Experience)
                  , ("Education", Education)
                  , ("Projects", Projects)
                  , ("Objective", Objective)
                  ]


-- App definition

theApp :: M.App (D.Dialog Choice) e ()
theApp =
    M.App { M.appDraw = drawUI
          , M.appChooseCursor = M.neverShowCursor
          , M.appHandleEvent = appEvent
          , M.appStartEvent = return
          , M.appAttrMap = const theMap
          }

main :: IO ()
main = do
    d <- M.defaultMain theApp initialState
    putStrLn "Goodbye!"


