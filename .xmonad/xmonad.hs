import XMonad
import Data.Monoid
import System.Exit
import Control.Monad (liftM2)

import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers(doFullFloat, doCenterFloat, isFullscreen, isDialog)

import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume, xF86XK_AudioMute)
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing
import XMonad.Layout.Renamed
import XMonad.Layout.IndependentScreens
import XMonad.Layout.NoBorders

import XMonad.Actions.CycleWS

import Data.Ratio
import Data.Maybe (fromJust)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myFont = "xft:JetBrainsMono Nerd Font Mono:size=10:bold:antialias=true"

myTerminal      = "urxvt"
myDMenu="dmenu_run -p [run]: -fn '" ++ myFont ++ "' -nb '" ++ gruvBg ++ "' -nf '" ++ gruvFgDark ++ "' -sf '" ++ gruvBg ++ "' -sb '" ++ gruvYellowLight ++ "' -h 21"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2
myModMask       = mod4Mask

myWorkspaceNames = ["term","web","dev","doc","mus","gfx","vid","sys","chat","rdp"]
mySwitcherKeys = [xK_1 .. xK_9] ++ [xK_0]
mySwitcherChars = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
myWsNameSep = replicate (length myWorkspaceNames) ":"
myWorkspaces = zipWith (++) (zipWith (++) mySwitcherChars myWsNameSep) myWorkspaceNames
myWorkspacesWithKeys = zip mySwitcherKeys myWorkspaces

clickable ws = "<action=xdotool key super+"++i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws (M.fromList $ zipWith (,) myWorkspaces mySwitcherChars)

-- Border colors for unfocused and focused windows, respectively.
--

myNormalBorderColor  = gruvGray
myFocusedBorderColor = gruvBlueLight

-----------------------------------------------------------------------------------------------------------
-- Gruvbox dark
--
gruvBg = "#282828"
gruvBgDark = "#1d2021"
gruvBgLight = "#665c54"
gruvFg = "#ebdbb2"
gruvFgDark = "#bdae93"
gruvFgLight = "#fbf1c7"
gruvRed = "#cc241d"
gruvRedLight = "#fb4934"
gruvGreen = "#98971a"
gruvGreenLight = "#b8bb26"
gruvYellow = "#d79921"
gruvYellowLight = "#fabd2f"
gruvBlue = "#458588"
gruvBlueLight = "#83a598"
gruvPurple = "#b16286"
gruvPurpleLight = "#d3869b"
gruvAqua = "#689d6a"
gruvAquaLight = "#8ec07c"
gruvOrange = "#d65d0e"
gruvOrangeLight = "#fe8019"
gruvGray = "#a89984"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn myDMenu)
    , ((modm,               xK_d     ), spawn myDMenu)

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Lock screen
    , ((modm .|. shiftMask .|. controlMask, xK_l), spawn "$HOME/.xmonad/extra/pixlock")

    -- Quit xmonad
    , ((modm .|. shiftMask .|. controlMask, xK_q), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask , xK_q), spawn "killall xmobar; xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    
    -- Shutdown
    , ((modm .|. shiftMask .|. controlMask, xK_Escape), spawn "shutdown now")
    ]
    ++

    -- Volume keys

    [   ((0, xF86XK_AudioMute), spawn "amixer set Master toggle")
      , ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 5%- unmute")
      , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 5%+ unmute")]
      
    ++
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((myModMask, key), (windows $ W.greedyView ws))
        | (key,ws) <- myWorkspacesWithKeys]
    ++
    [((myModMask .|. shiftMask, key), (windows $ W.shift ws))
        | (key,ws) <- myWorkspacesWithKeys]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

myLayout = layoutTall ||| layoutSpiral ||| layoutGrid ||| layoutMirror ||| layoutFull
    where
      layoutTall = renamed [Replace "T"] $ smartBorders $ smartSpacing 5 $ avoidStruts (Tall 1 (3/100) (1/2))
      layoutSpiral = renamed [Replace "S"] $ smartBorders $ smartSpacing 5 $ avoidStruts (spiral (125 % 146))
      layoutGrid = renamed [Replace "G"] $ smartBorders $ smartSpacing 5 $ avoidStruts (Grid)
      layoutMirror = renamed [Replace "M"] $ smartBorders $ smartSpacing 5 $ avoidStruts (Mirror (Tall 1 (3/100) (3/5)))
      layoutFull = renamed [Replace "F"] $ smartBorders $ smartSpacing 5 $ avoidStruts (Full)

------------------------------------------------------------------------
-- Window rules:
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61612" | x <- my1Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "2:web" | x <- my2Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "3:dev" | x <- my3Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61635" | x <- my4Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61502" | x <- my5Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61501" | x <- my6Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61705" | x <- my7Shifts]
    -- , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "\61564" | x <- my8Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "9:chat" | x <- my9Shifts]
    , [(className =? x <||> title =? x <||> resource =? x) --> doShiftAndGo "0:rdp" | x <- my10Shifts]
    ]
    where
    doShiftAndGo = doF . liftM2 (.) W.greedyView W.shift
    myCFloats = ["Arandr", "nm-connection-editor"]
    myTFloats = ["Downloads", "Save As..."]
    myRFloats = []
    myIgnores = ["desktop_window", "kdesktop"]
    -- my1Shifts = ["Chromium", "Vivaldi-stable", "Firefox"]
    my2Shifts = ["google-chrome"]
    my3Shifts = ["code"]
    -- my4Shifts = []
    -- my5Shifts = ["Gimp", "feh"]
    -- my6Shifts = ["vlc", "mpv"]
    -- my7Shifts = ["Virtualbox"]
    -- my8Shifts = ["Thunar"]
    my9Shifts = ["telegram-desktop"]
    my10Shifts = ["org.remmina.Remmina"]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    setWMName "LG3D"
    --spawnOnce "xrandr --output LVDS-1 --primary --mode 1366x768 --pos 277x1080 --rotate normal --output VGA-1 --off --output LVDS-1-1 --off --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal --output VGA-1-1 --off &"
    spawnOnce "xrandr --output LVDS-1 --primary --mode 1366x768 --pos 277x1080 --rotate normal --output VGA-1 --mode 1920x1080 --pos 0x0 --rotate normal"
    -- spawnOnce "xrandr --output LVDS1 --primary --mode 1366x768 --pos 277x1080 --rotate normal --output VGA1 --off --output VIRTUAL1 --off --output LVDS-1-1 --off --output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal --output VGA-1-1 --off &"
    spawnOnce "setxkbmap -layout us,ir -option grp:caps_toggle &"
    spawnOnce "nitrogen --restore &"
    spawnOnce "trayer --monitor primary --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype request --transparent true --alpha 0 --tint 0x282828  --height 21 &"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 /home/mozi/.config/xmobar/xmobar0.hs"
    xmproc1 <- spawnPipe "xmobar -x 1 /home/mozi/.config/xmobar/xmobar1.hs"
    -- n <- countScreens
    -- xmprocs <- mapM (\i -> spawnPipe $ "xmobar /home/mozi/.config/xmobar/xmobar-" ++ show i ++ ".sh -x " ++ show i) [0..n-1]
    -- xmprocs <- mapM (\i -> spawnPipe $ "xmobar /home/mozi/.config/xmobar/xmobar.sh -x " ++ show i) [0..n-1]
    xmonad $ withUrgencyHook NoUrgencyHook $ docks defaults {
        logHook = dynamicLogWithPP $ xmobarPP { 
            ppOutput = \x -> hPutStrLn xmproc0 x
                          >> hPutStrLn xmproc1 x
            , ppCurrent = xmobarColor gruvYellowLight "" . wrap "[" "]" -- Current workspace in xmobar
            , ppVisible = xmobarColor gruvPurpleLight "" . clickable               -- Visible but not current workspace
            , ppHidden = xmobarColor gruvFgDark "" . wrap "" "" . clickable   -- Hidden workspaces in xmobar
            , ppTitle = xmobarColor gruvBlueLight "" . shorten 30     -- Title of active window in xmobar
            , ppUrgent = xmobarColor gruvRedLight "" . wrap "!" "!" . clickable  -- Urgent workspace
            , ppSep     = " | "
            , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
        }
    }



-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
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
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]

