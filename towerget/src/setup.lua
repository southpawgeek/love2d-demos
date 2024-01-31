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
require 'obj/Mob'        -- enemies
require 'obj/Block'      -- towers
require 'obj/Projectile' -- bullets fired by Block

-- Push uses this to create the window
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

-- normalized delta time
NDT = 0

-- current screen state, note the states in the screens directory update this
SCREEN = ''

-- refresh rate, this can change if you fullscreen or drag to different monitors
REFRESH = 0

-- (probably) constant values
-- window title
TITLE = 'cool game title'

-- the game gets scaled to this resolution
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- mouse button constants
PRIMARY_BUTTON = 1   -- usually left-click unless OS settings alter it
SECONDARY_BUTTON = 2 -- usually right-click
THIRD_BUTTON = 3     -- usually middle-click

-- utilities
-- sets the refresh rate global, defaults to 60
function getRefresh()
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
