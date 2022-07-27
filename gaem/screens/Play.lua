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

    if Control:down 'left' then
        Player.dx = Player.dx - dt * Player.speed
    end

    if Control:down 'right' then
        Player.dx = Player.dx + dt * Player.speed
    end

    if Control:down 'up' then
        Player.dy = Player.dy - dt * Player.speed
    end

    if Control:down 'down' then
        Player.dy = Player.dy + dt * Player.speed
    end

    if not Control:down 'left' and not Control:down 'right' then
        Player.dx = 0
    end

    if not Control:down 'up' and not Control:down 'down' then
        Player.dy = 0
    end

    if Control:down 'action' then
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