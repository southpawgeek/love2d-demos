-- load in localized strings
require 'src/strings'
require 'src/tuning'

-- use third-party stuff
Class = require 'lib/class'
Push = require 'lib/push'

require 'lib/BaseState'
require 'lib/StateMachine'

-- screen states
require 'screens/Title'
require 'screens/Play'
require 'screens/GameOver'

require 'obj/Hoem'       -- the core
require 'obj/HoemHud'    -- HUD for core (separate from shake-able world)
require 'obj/Mob'        -- enemies
require 'obj/Projectile' -- bullets + ProjectileTypes (before Block)
require 'obj/Block'      -- towers

-- Push uses this to create the window
WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 600

-- normalized delta time
NDT = 0

-- current screen state, note the states in the screens directory update this
SCREEN = ''

-- refresh rate, this can change if you fullscreen or drag to different monitors
REFRESH = 0

-- (probably) constant values
-- window title
TITLE = 'Tower Get'

-- the game gets scaled to this resolution
VIRTUAL_WIDTH = 360
VIRTUAL_HEIGHT = 180

-- mouse button constants
PRIMARY_BUTTON = 1   -- usually left-click unless OS settings alter it
SECONDARY_BUTTON = 2 -- usually right-click
THIRD_BUTTON = 3     -- usually middle-click

-- utilities
-- sets the refresh rate global, defaults to 60
function GetRefresh()
    local undef, undef, flags = love.window.getMode()
    REFRESH = flags.refreshrate
    if REFRESH == 0 then REFRESH = 60 end
    print('setting refresh rate to ' .. REFRESH)
end

-- state machine for screens
Screen = StateMachine {
    ['Title'] = function() return Title() end,
    ['Play'] = function() return Play() end,
    ['GameOver'] = function() return GameOver() end
}

LANG = 'en'
LOC = S[LANG]
