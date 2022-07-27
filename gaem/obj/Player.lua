Player = Class{}

function Player:init()
    print('init Player')
    self.x = VIRTUAL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2
    self.dx = 0
    self.dy = 0
    self.speed = 20
end

function Player:render()
   love.graphics.setColor(1, 0, 1, 1)
   love.graphics.rectangle('fill', self.x, self.y, 10, 10)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print("loc: " .. math.floor(Player.x) .. "/" .. math.floor(Player.y), 5, 10)
end

function Player:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- just wrap around the screen for now
    if self.x < -10 then
        self.x = VIRTUAL_WIDTH
    end

    if self.x > VIRTUAL_WIDTH + 10 then
        self.x = 0
    end

    if self.y < -10 then
        self.y = VIRTUAL_HEIGHT
    end

    if self.y > VIRTUAL_HEIGHT + 10 then
        self.y = 0
    end
end

function Player:shoot()
    table.insert(Projectiles, Projectile(self.x, self.y, math.random(6, 36)))
end