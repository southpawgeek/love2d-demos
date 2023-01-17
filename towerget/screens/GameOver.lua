GameOver = Class{__includes = BaseState}
GameOver._name = 'Game Over'

function GameOver:enter()
    SCREEN = self._name
end

function GameOver:render()
    love.graphics.print('you died :( enter to play again, esc to title', 0, 0)
end

function GameOver:update(dt)
    -- enter takes you to the play screen
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        Screen:change('Play')
    end

    -- if you hit esc on title screen, exit
    if love.keyboard.wasPressed('escape') then
        Screen:change('Title')
    end
end