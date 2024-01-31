Mob = Class {}

function Mob:init(x, y)
    self.x, self.y = self:getSpawnPoint()
    self.destx, self.desty = x, y
    self.speed = math.random(10, 50)
    self.size = math.random(3, 9)
    self.alive = true
    print('init mob: ' .. self.x .. '/' .. self.y)
end

function Mob:exit()
    self.alive = false
    --print('mob dead')
end

function Mob:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

function Mob:update(dt)
    local angle = math.atan2(self.desty - self.y, self.destx - self.x)
    self.x = self.x + math.cos(angle) * self.speed * dt
    self.y = self.y + math.sin(angle) * self.speed * dt
end

function Mob:getSpawnPoint()
    local x, y = 0, 0
    local ignore_x_or_y = math.random(0, 1)
    if ignore_x_or_y == 0 then
        x = math.random(VIRTUAL_WIDTH)
        y = math.random(0, 1) * VIRTUAL_HEIGHT
    else
        x = math.random(0, 1) * VIRTUAL_WIDTH
        y = math.random(VIRTUAL_HEIGHT)
    end
    return x, y
end

function Mob:collides(hoem)
    if self.x > hoem.x + hoem.size or hoem.x > self.x + self.size then
        return false
    end

    if self.y > hoem.y + hoem.size or hoem.y > self.y + self.size then
        return false
    end

    return true
end
