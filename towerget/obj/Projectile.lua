Projectile = Class {}

function Projectile:init(x, y, angle)
    self.x, self.y = x, y
    self.angle = angle
    self.speed = 30
    self.size = 2
    self.duration = 0.5
    self.alive = true
    --print('init Projectile: ' .. self.x .. '/' .. self.y .. ' angle: ' .. self.angle)
end

function Projectile:exit()
    self.alive = false
    --print('projectile dead')
end

function Projectile:render()
    love.graphics.setColor(1, 0, 1, 1)
    love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end

function Projectile:update(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt

    -- projectile dies after duration is done
    self.duration = self.duration - dt
    if self.duration <= 0 then
        self:exit()
    end
end

function Projectile:collides(mob)
    local projLeft = self.x - self.size / 2
    local projRight = self.x + self.size / 2
    local projTop = self.y - self.size / 2
    local projBottom = self.y + self.size / 2
    local mobLeft = mob.x - mob.size / 2
    local mobRight = mob.x + mob.size / 2
    local mobTop = mob.y - mob.size / 2
    local mobBottom = mob.y + mob.size / 2

    if projRight < mobLeft or mobRight < projLeft then
        return false
    end
    if projBottom < mobTop or mobBottom < projTop then
        return false
    end

    return true
end
