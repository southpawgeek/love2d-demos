BaseState = Class{}

-- runs once
function BaseState:init() end

-- runs every time we switch to this
function BaseState:enter() end

-- runs every time we switch from this
function BaseState:exit() end

-- this is called from main love.draw()
function BaseState:render() end

-- this is called from main love.update(dt)
function BaseState:update(dt) end
