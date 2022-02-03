Asteroid = Class{}

function Asteroid:init(size)
    -- velocity
    self.dx = math.random(70, 120)

    -- direction
    direction = math.random(2)

    if direction == 1 then
        self.x = 0
    else
        self.x = VIRTUAL_WIDTH
        self.dx = self.dx * -1
    end

    self.y = math.random(0, 100)

    self.width = size
    self.height = size
end

function Asteroid:collides(player)
    if self.x > player.x + player.width or player.x > self.x + self.width then
        return false
    end

    if self.y > player.y + player.height or player.y > self.y + self.height then
        return false
    end 

    return true
end

function Asteroid:update(dt)
    self.x = self.x + self.dx * dt
end

function Asteroid:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end