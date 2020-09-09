import XMonad
import XMonad.Layout.Gaps
import XMonad.Layout.MouseResizableTile
import XMonad.Layout
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Grid
import XMonad.ManageHook
import qualified XMonad.StackSet as W
import Data.Bits ((.|.))
import Data.Default
import Data.Monoid
import qualified Data.Map as M
import System.Exit
import XMonad.Hooks.InsertPosition
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import Data.List (sortBy)
import Data.Function (on)
import Control.Monad (forM_, join)
import XMonad.Util.Run (safeSpawn)
import qualified XMonad.StackSet as W
import XMonad.Layout.Minimize
import qualified XMonad.Layout.MultiToggle           as MTog
import qualified XMonad.Layout.MultiToggle.Instances as MTog
import qualified XMonad.Layout.ToggleLayouts         as ToggleLayouts
import XMonad.Layout.SimpleDecoration
import XMonad.Actions.Minimize
import qualified FancyBorders
import qualified XMonad.Layout.PerScreen             as PerScreen
import qualified XMonad.Layout.BoringWindows as BW
import XMonad.Layout.Spacing (spacingRaw, Border(..), toggleWindowSpacingEnabled, incScreenWindowSpacing, decScreenWindowSpacing)
import XMonad.Util.EZConfig
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Config.Desktop
import XMonad.Util.SpawnOnce
import XMonad.Hooks.SetWMName
import XMonad.Layout.BoringWindows as BoringWindows

---- Config

mySelectScreenshot = "select-screenshot"

myStartupHook :: X()
myStartupHook = do
  spawnOnce "polybar -r main -c ~/.config/polybar/config.ini"
  spawnOnce "picom"
  spawnOnce "feh --bg-scale ~/Pictures/space.png"
  spawnOnce "export _JAVA_AWT_WM_NONREPARENTING=1"

myLayout = avoidStruts
         $ let tall = Tall 1 (3/100) (1/2) in tall ||| Mirror tall

myLayout2 = spacingRaw True (Border 10 10 10 10) True (Border 10 10 10 10) True $
             layoutHook def

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    ---- Launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    
    ---- Close focused window
    , ((modm .|. shiftMask, xK_c), kill)

    ---- Return to tiled
    , ((modm,               xK_t), withFocused $ windows . W.sink)

    ---- Change Tiling 'mode'
    , ((modm,               xK_space), sendMessage NextLayout)

    ---- Move Focus
    , ((modm,               xK_Tab), windows W.focusDown)
    
    ---- Restart Xmonad
    , ((modm,               xK_q), spawn "xmonad --restart")

    ---- Exit Xmonad
    , ((modm .|. shiftMask, xK_q), io (exitWith ExitSuccess))

    ---- Minimize and maximize windows
    , ((modm,               xK_m), withFocused minimizeWindow)
    , ((modm .|. shiftMask, xK_m), withLastMinimized maximizeWindowAndFocus)

    ---- Take a screenshot
    , ((modm,               xK_s), spawn "flameshot gui")
    , ((modm .|. shiftMask, xK_s), spawn "scrot")

    ---- Force close
    , ((modm .|. shiftMask, xK_k), spawn "xkill")

    , ((modm,               xK_d), spawn "pkill dunst; dunst")
    , ((modm .|. shiftMask, xK_g), spawn "notify-send 'Test' 'body element'")
---    , ((modm,               xK_r), spawn "~/Documents/Polyba/hehe/launch.sh")
    , ((modm .|. shiftMask, xK_r), spawn "~/Documents/Polyba/hehe/close.sh")
    ]
    ++ 

    ---- Switch Workspaces
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
              
--- Main

main = do
    xmonad  . ewmh . docks $ def
        { terminal = "kitty"
        , modMask = mod1Mask
        , borderWidth = 0
        , keys = myKeys
        , manageHook = insertPosition Below Newer <+> manageDocks <+> (isFullscreen --> doFullFloat) <+> manageHook def <+> composeAll [ className =? "feh" --> doFloat , className =? "yad-calendar" --> doFloat ]
        , handleEventHook = handleEventHook def <+> fullscreenEventHook
        , layoutHook = myLayout ||| myLayout2
        , startupHook = myStartupHook
        }
