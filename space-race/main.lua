push = require 'lib/push'
Class = require 'lib/class'

require 'lib/StateMachine'
require 'states/BaseState'
require 'states/TitleScreenState'
require 'states/CountdownState'
require 'states/PlayState'
require 'classes/Asteroid'
require 'classes/Player'

WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 576

VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

--[[
    https://love2d.org/wiki/Tutorial:Callback_Functions
]]

-- https://love2d.org/wiki/love.load
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Spaec Raec')
    math.randomseed(os.time())
    bigFont = love.graphics.newFont('assets/retro_computer.ttf', 28, 'mono')
    tinyFont = love.graphics.newFont('assets/retro_computer.ttf', 7, 'mono')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('title')

    sounds = {
        ['boom'] = love.audio.newSource('assets/boom2.wav', 'static'),
        ['yay'] = love.audio.newSource('assets/yay.wav', 'static')
    }

    -- particle stuff for later
    particle = love.graphics.newCanvas(1, 1)
    love.graphics.setCanvas(particle)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    love.graphics.setCanvas()

	psystem = love.graphics.newParticleSystem(particle, 32)
	psystem:setParticleLifetime(0.5, 2)
	psystem:setLinearAcceleration(5, 5, 25, 25)
	psystem:setColors(1, 0.5, 0, 1, 1, 0, 0, 0)
    -- end particle stuff

    -- initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

-- https://love2d.org/wiki/love.update
function love.update(dt)
    gStateMachine:update(dt)

    -- particle system doesn't do anything yet
    psystem:update(dt)

    love.keyboard.keysPressed = {}
end

-- https://love2d.org/wiki/love.draw
-- if you don't put graphics stuff here, it won't show up
function love.draw()
    push:apply('start')

    love.graphics.setColor(0.7, 0.6, 0, 1)
    love.graphics.rectangle('fill', 0, 140, VIRTUAL_WIDTH, 4)
    love.graphics.setColor(1, 1, 1, 1)

    gStateMachine:render()

    push:apply('end')
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end


function love.conf(t)
    t.console = true
end