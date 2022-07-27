-- use third-party stuff
Camera = require 'lib/camera'
Class = require 'lib/class'
Push = require 'lib/push'
Baton = require 'lib/baton'

require 'lib/BaseState'
require 'lib/StateMachine'

-- game objects
require 'obj/Player'
require 'obj/Projectile'

-- screen states
require 'screens/Title'
require 'screens/Play'

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
VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

-- mouse button constants
PRIMARY_BUTTON = 1 -- usually left-click unless OS settings alter it
SECONDARY_BUTTON = 2 -- usually right-click
THIRD_BUTTON = 3 -- usually middle-click

-- utilities
-- sets the refresh rate global, defaults to 60
function getRefresh()
    undef, undef, flags = love.window.getMode()
    REFRESH = flags.refreshrate
    if REFRESH == 0 then REFRESH = 60 end
    print('setting refresh rate to ' .. REFRESH)
end

-- state machine for screens
Screen = StateMachine {
    ['Title'] = function() return Title() end,
    ['Play'] = function() return Play() end
}

-- control stuff
Control = Baton.new {
    controls = {
        left = {'key:left', 'axis:leftx-', 'button:dpleft'},
        right = {'key:right', 'axis:leftx+', 'button:dpright'},
        up = {'key:up', 'axis:lefty-', 'button:dpup'},
        down = {'key:down', 'axis:lefty+', 'button:dpdown'},
        action = {'key:space', 'key:return', 'button:a', 'mouse:1'},
    },
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[1],
    deadzone = .33
}