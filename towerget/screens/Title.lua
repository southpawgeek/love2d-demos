Title = Class{__includes = BaseState}
Title._name = 'Tower Get'

function Title:enter()
    SCREEN = self._name
end

function Title:render()
    love.graphics.print('press enter to play or esc to quit', 0, 0)
end

function Title:update(dt)
    -- enter takes you to the play screen
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        Screen:change('Play')
    end

    -- if you hit esc on title screen, exit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end