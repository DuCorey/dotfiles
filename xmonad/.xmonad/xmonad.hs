import System.Exit
import qualified Data.List as L
import qualified Data.Map as M
import GHC.IO.Handle
import Control.Monad (liftM2)

-- Xmonad Core
import XMonad
import qualified XMonad.StackSet as W

-- Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.SimpleFloat
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Minimize

-- Actions
import XMonad.Actions.Navigation2D
import XMonad.Actions.GridSelect
import XMonad.Actions.UpdatePointer
import XMonad.Actions.SpawnOn
import XMonad.Actions.CycleWS

--Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.DynamicBars
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks

--Utils
import XMonad.Util.Run
import XMonad.Util.EZConfig
import Graphics.X11.ExtraTypes.XF86


-- Xmonad entry point
main :: IO()
main = xmonad =<< statusBar myBar myLogPP toggleStrutsKey (ewmh $ myConfig)


-- Config
myConfig  =  def {

    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    clickJustFocuses   = myClickJustFocuses,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,

    --hooks, layouts
    layoutHook         = myLayoutHook,
    manageHook         = myManageHook,
    handleEventHook    = myEventHook,
    startupHook        = myStartupHook,
    logHook            = mylogHook
    }


-- Xmobar
myBar = "xmobar"
myLogPP :: PP
myLogPP = xmobarPP { ppCurrent = xmobarColor "#51afef" "" -- . wrap "[" "]"
                   , ppTitle = xmobarColor "#c678dd" "" . shorten 50
                   , ppLayout = xmobarColor "#ecbe7b" "" . myIcons
                   , ppHiddenNoWindows = xmobarColor "#373b41" ""
                   , ppSep = xmobarColor "#c5c8c6" "" " | "
                   , ppWsSep = " "
                   }

myLogPPActive :: PP
myLogPPActive = myLogPP { ppCurrent = xmobarColor "#51afef" ""}

barCreator :: DynamicStatusBar
barCreator (S sid) = spawnPipe $ "xmobar --screen " ++ show sid

barDestroyer :: DynamicStatusBarCleanup
barDestroyer = return ()


-- urxvt with fish as terminal
myTerminal = "urxvt -e /bin/fish"

-- Window focus follows mouse
myFocusFollowsMouse = True

-- Clicking on window focuses and passes the click forward
myClickJustFocuses = False

-- Width of the window border in pixels
myBorderWidth = 4

--Defines which mod key to use (mod4maks == super)
myModMask = mod4Mask

-- Define and name each workspace
--- The workspaces are font awesome version 5 (https://fontawesome.com/icons?d=gallery)
myws1 = "\xf120" -- terminal
myws2 = "\xf269" -- firefox
myws3 = "\xf121" -- code
myws4 = "\xf07b" -- folder
myws5 = "\xf0e0" -- email
myws6 = "\xf075" -- chat
myws7 = "\xf02d" -- reading
myws8 = "\xf15c" -- writing
myws9 = "\xf0ce" -- table
myExtraWorkspaces = [(xK_0, "\xf03d"),
                     (xK_minus, "...")]
myWorkspaces :: [WorkspaceId]
myWorkspaces = [myws1, myws2, myws3, myws4, myws5, myws6, myws7, myws8, myws9] ++ (map snd myExtraWorkspaces)

-- Set border color when unfocused
myNormalBorderColor = "#2c323c"

-- Set border color when focused
myFocusedBorderColor = "#51afef"

-- Scratch Pads
--myScratchpads = [NS "termscratch" "urxvt -e /bin/fish" (className =? "termscratch") (customFloating $ W.RationalRect (1/10) (1/10) (4/5) (4/5))]


-- Key bindings
--- Toggle the status bar gap
toggleStrutsKey XConfig {XMonad.modMask = modm} = (modm, xK_b)

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

  -- launch a terminal
  [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

  -- launch filebrowser
  , ((modm .|. controlMask, xK_f) , spawn "nemo")

  -- launch rofi
  , ((modm,                 xK_p), spawn "rofi -combi-modi drun,run -show combi -modi combi")
  , ((modm .|. shiftMask,   xK_p), spawn "rofi -show window")
  , ((modm .|. altMask,     xK_p), spawn "rofi -show ssh")
  , ((modm .|. controlMask, xK_p), spawn "rofi -show fb -modi fb:~/.bin/rofi-file-browser.sh")
  , ((modm .|. shiftMask,   xK_f), spawn "rofi -show find -modi find:~/.bin/rofi-finder.sh")

  -- launch thunderbird mail client
  , ((modm .|. controlMask, xK_m), spawn "thunderbird")

  -- launch emacs editor
  , ((modm .|. controlMask, xK_e), spawn "emacs")

  -- launch firefox broswer
  --, ((modm .|. controlMask, xK_i), spawn "firefox")

  -- close focused window
  , ((modm .|. shiftMask, xK_c), kill)

  -- Grid Select
  , ((modm, xK_g), goToSelected def)

  -- Rotate through the available layout algorithms
  , ((modm, xK_space), sendMessage NextLayout)

  -- Reset the layouts on the current workspace to default
  , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct sie
  , ((modm .|. shiftMask, xK_r), refresh)

  -- Move focus to the next window
  --, ((modm, xK_Tab), windows W.focusDown)

  -- Move focus to the previous window
  --, ((modm .|. shiftMask, xK_Tab), windows W.focusUp)

  -- Move focus to previous workspace
  --, ((modm, xK_grave), toggleWS' ["NSP"])

  -- Minize selected window
  --, ((modm, xK_m), withFocused minimizeWindow)

  -- Restore one minimized window
  --, ((modm .|. shiftMask, xK_m), sendMessage RestoreNextMinimizedWin)

  -- Maximize selected window
  , ((modm, xK_f), (sendMessage $ Toggle FULL))

  -- Swap the focused window and the master window
  , ((modm .|. controlMask, xK_Return), windows W.swapMaster)

  -- Move focus to the master window
  , ((modm, xK_Return), windows W.focusMaster)

  -- Swap the focused window with the next window
  --, ((modm .|. controlMask .|. shiftMask, xK_k), windows W.swapDown)

  -- Swap the focused window with the previous window
  --, ((modm .|. controlMask .|. shiftMask, xK_j), windows W.swapUp)

  -- Shrink the master area
  --, ((modm .|. controlMask, xK_i), sendMessage Shrink)
  --, ((modm .|. controlMask, xK_u), sendMessage MirrorShrink)

  -- Expand the master area
  --, ((modm .|. controlMask, xK_o), sendMessage Expand)
  --, ((modm .|. controlMask, xK_i), sendMessage MirrorExpand)

  -- Push window back into tiling
  , ((modm, xK_t), withFocused $ windows . W.sink)

  -- -- Increment the number of windows in the master area
  -- , ((modm, xK_comma), sendMessage (IncMasterN 1))

  -- -- Decrement the number of windows in the master area
  -- , ((modm, xK_period), sendMessage (IncMasterN (-1)))

  -- Switch to last workspace
  , ((modm, xK_Tab), toggleWS)

  -- Switch workspaces
--  , ((modm, xK_Right), moveTo Next)
--  , ((modm, xK_Left), moveTo Prev)
--  , ((modm .|. shiftMask, xK_Right), shiftTo Next)
--  , ((modm .|. shiftMask, xK_Left), shiftTo Prev)

  -- Directional Navigation & Moving of Windows
  , ((modm,               xK_l), windowGo R False)
  , ((modm,               xK_j), windowGo L False)
  , ((modm,               xK_i), windowGo U False)
  , ((modm,               xK_k), windowGo D False)
  , ((modm .|. shiftMask, xK_l), windowSwap R False)
  , ((modm .|. shiftMask, xK_j), windowSwap L False)
  , ((modm .|. shiftMask, xK_i), windowSwap U False)
  , ((modm .|. shiftMask, xK_k), windowSwap D False)

  -- Switch screens
--  , ((modm .|. shiftMask, xK_o), swapNextScreen)

  -- Move current window to next monitor
--  , ((modm .|. controlMask, xK_o), shiftNextScreen)

  -- Quit xmonad
  , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))

  -- Restart xmonad
  , ((modm              , xK_q), spawn "xmonad --recompile; xmonad --restart")

  -- Change keyboard layout
  , ((modm .|. shiftMask, xK_space), spawn "~/.config/fish/functions/layout_switch.fish")

  -- Brightness control
    --- Screen
  , ((0, xF86XK_MonBrightnessUp), spawn "~/.bin/brightness up")
  , ((0, xF86XK_MonBrightnessDown), spawn "~/.bin/brightness down")
    --- Keyboard Backlight
  --, ((0, xF86XK_KbdBrightnessUp), spawn "~/.bin/keyboard_brightness up")
  --, ((0, xF86XK_KbdBrightnessDown), spawn "~/.bin/keyboard_brightness down")

  -- Volume control
  , ((0, xF86XK_AudioMute), spawn "~/.bin/volume mute")
  , ((0, xF86XK_AudioLowerVolume), spawn "~/.bin/volume down")
  , ((0, xF86XK_AudioRaiseVolume), spawn "~/.bin/volume up")

  -- Lockscreen
  , ((modm, xK_x), spawn "betterlockscreen -l dim")
  ]

  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  ++ [
  ((m .|. modm, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]

  -- mod-[extraworkspace], Switch to extra workspace
  -- mod-shift-[extraworkspace], Move window to extra workspace
  ++ [
  ((myModMask, key), (windows $ W.greedyView ws))
  | (key,ws) <- myExtraWorkspaces
  ] ++ [
  ((myModMask .|. shiftMask, key), (windows $ W.shift ws))
  | (key,ws) <- myExtraWorkspaces
  ]

-- Layout definition & modifiers
myLayoutHook = smartBorders $ layoutHook def

-- Defined icons for various layout types
myIcons layout
    | is "Mirror ResizableTall" = "<icon=/home/corey/.xmonad/icons/layout-mirror.xbm/>"
    | is "ResizableTall" = "<icon=/home/corey/.xmonad/icons/layout-tall.xbm/>"
    | is "BSP" = "<icon=/home/corey/.xmonad/icons/layout-bsp.xbm/>"
    | is "Full" = "<icon=/home/corey/.xmonad/icons/layout-full.xbm/>"
    | is "Simple Float" = "<icon=/home/corey/.xmonad/icons/layout-float.xbm/>"
    | otherwise = "<icon=/home/corey/.xmonad/icons/layout-gimp.xbm/>"
  where is = (`L.isInfixOf` layout)

-- Startup hook
myStartupHook = do
  startupHook def
  spawn "compton --config ~/.config/compton/compton.conf"
  spawn "xinput set-prop 'DELL08AF:00 06CB:76AF Touchpad' 'libinput Tapping Enabled' 1"
  setFullscreenSupported
  dynStatusBarStartup barCreator barDestroyer



-- Alias for left alt key modifier
altMask = mod1Mask

-- Manage hook defining various window rules
myManageHook = composeAll [
  isFullscreen --> doFullFloat,
  className =? "Emacs" --> viewShift myws3,
  className =? "Thunderbird" --> viewShift myws5,
  className =? "discord" --> viewShift myws6,
  className =? "Skype" --> doShift myws6,
  appName   =? "endnote.exe" --> viewShift myws7,
  className =? "libreoffice-calc" --> viewShift myws9,
  className =? "libreoffice-writer" --> viewShift myws8,
  className =? "libreoffice-startcenter" --> viewShift myws8,
  className =? "Zathura" --> viewShift myws7,
  className =? "vlc" --> viewShift (myWorkspaces!!9),
  manageDocks,
  manageHook defaultConfig
  ]
  where viewShift = doF . liftM2 (.) W.greedyView W.shift

-- Event hooks
myEventHook = composeAll [
  fullscreenEventHook,
  docksEventHook,
  dynStatusBarEventHook barCreator barDestroyer,
  handleEventHook def
  ]

-- Log Hooks
mylogHook = do
  multiPP myLogPPActive myLogPP


-- Fullscreen Firefox support
setFullscreenSupported :: X ()
setFullscreenSupported = withDisplay $ \dpy -> do
    r <- asks theRoot
    a <- getAtom "_NET_SUPPORTED"
    c <- getAtom "ATOM"
    supp <- mapM getAtom ["_NET_WM_STATE_HIDDEN"
                         ,"_NET_WM_STATE_FULLSCREEN" -- XXX Copy-pasted to add this line
                         ,"_NET_NUMBER_OF_DESKTOPS"
                         ,"_NET_CLIENT_LIST"
                         ,"_NET_CLIENT_LIST_STACKING"
                         ,"_NET_CURRENT_DESKTOP"
                         ,"_NET_DESKTOP_NAMES"
                         ,"_NET_ACTIVE_WINDOW"
                         ,"_NET_WM_DESKTOP"
                         ,"_NET_WM_STRUT"
                         ]
    io $ changeProperty32 dpy r a c propModeReplace (fmap fromIntegral supp)
    setWMName "xmonad"
