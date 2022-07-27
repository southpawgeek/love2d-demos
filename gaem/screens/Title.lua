Title = Class{__includes = BaseState}
Title._name = 'Title'

function Title:enter()
    SCREEN = self._name
end

function Title:render()
    love.graphics.print('press enter or A to play or esc to quit', 0, 0)
end

function Title:update(dt)
    if Control:pressed 'action' then
        Screen:change('Play')
    end

    -- if you hit esc on title screen, exit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end