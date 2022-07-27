Play = Class{__includes = BaseState}
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
end

function Play:render()
    Player:render()

    for k, item in pairs(Projectiles) do
        item:render()
    end
end

function Play:update(dt)
    -- esc to go back to title
    if love.keyboard.wasPressed('escape') then
        Screen:change('Title')
    end

    -- arrow controls
    if love.keyboard.isDown('up') then
        Player.dy = Player.dy - 1
    end

    if love.keyboard.isDown('down') then
        Player.dy = Player.dy + 1
    end

    if love.keyboard.isDown('left') then
        Player.dx = Player.dx - 1
    end

    if love.keyboard.isDown('right') then
        Player.dx = Player.dx + 1
    end

    -- left stick controls
    lx, ly = Joystick:getAxes()
    Player.dx = Player.dx + lx
    Player.dy = Player.dy + ly

    print(lx, ly)

    if love.keyboard.isDown('space') or Joystick:isDown(1) then
        Player:shoot()
    end

    Player:update(dt)

    -- update projectiles
    for k, item in pairs(Projectiles) do
        item:update(dt)
    end

    -- remove dead projectiles
    for k, item in pairs(Projectiles) do
        if item.dead then
            table.remove(Projectiles, k)
        end
    end
end