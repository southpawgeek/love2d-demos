Play = Class{__includes = BaseState}
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
end

function Play:render()
    love.graphics.print('game would go here, press esc to go back to title', 0, 0)
end

function Play:update(dt)
    -- esc to go back to title
    if love.keyboard.wasPressed('escape') then
        Screen:change('Title')
    end
end