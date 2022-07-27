-- load some third-party libraries and initialize some other stuff
require 'src/setup'

-- runs once on application start
function love.load()
    -- without this, randomized stuff will not be random
    math.randomseed(os.time())
    -- set window title
    love.window.setTitle(TITLE)
    -- this keeps the pixels looking pixelly
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Push does some stuff
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- get refresh rate so our dt/NDT stuff is nice
    getRefresh()

    Joystick = {}

    local joysticks = love.joystick.getJoysticks()
    for i, joystick in ipairs(joysticks) do
        if joystick:isConnected() then
            Joystick = joystick
        end
    end

    -- initialize keys and mouse button tables
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
    love.joystick.buttonsPressed = {}

    -- start by loading the Title Screen
    Screen:change('Title')

    Player = Player()
    Projectiles = {}
end

-- this is the game loop, dt is usually a fraction of a second
function love.update(dt)
    -- keep a running total of time passed
    NDT = NDT + dt

    -- only update once per.. hz?
    if NDT > 1/REFRESH then
        Screen:update(NDT)
        -- if NDT is over 1 second, reset it to the remainder
        NDT = NDT % 1/REFRESH

        -- refresh these tables because they were handled by the Screen:update method
        love.keyboard.keysPressed = {}
        love.mouse.buttonsPressed = {}
        love.joystick.buttonsPressed = {}
    end
end

-- renders graphics, probably don't need to touch this
function love.draw()
    Push:start()
    Screen:render()
    Push:finish()
end

-- Push thing, can leave this alone
function love.resize(w, h)
    Push:resize(w, h)
    getRefresh()
end

-- sets a bool so we know what key is pressed
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

-- returns a bool of whether the key was pressed
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.gamepadpressed(joystick, button)
    love.joystick.buttonsPressed[button] = true
end

function love.joystick.wasPressed(button)
   return love.joystick.wasPressed[button]
end