Block = Class {}

function Block:init(x, y)
    self.x = x
    self.y = y

    self.maxhealth = 10
    self.health = 10
    self.points = 5
    self.projectiles = {}
    self.fire = 0
    self.speed = 0.2
    print('init block: ' .. self.x .. '/' .. self.y)
end

function Block:exit()
    --print('block dead')
end

function Block:render()
    local ratio = self:healthPercent()
    love.graphics.setColor(0, 1, 1, ratio)
    love.graphics.rectangle('fill', self.x, self.y, 3, 3)

    -- render all child projectiles
    for k, projectile in pairs(self.projectiles) do
        projectile:render()
    end
end

function Block:update(dt)
    -- remove dead projectiles
    for k, projectile in pairs(self.projectiles) do
        projectile:update(dt)
        if projectile.alive == false then
            table.remove(self.projectiles, k)
        end
    end

    self.fire = self.fire + dt
    -- fire new projectile
    if self.fire >= self.speed then
        local random_angle = math.random() * math.pi * 2
        table.insert(self.projectiles, Projectile(self.x, self.y, random_angle))
        self.fire = 0
    end
end

function Block:collides(mob)
    if math.abs(self.x - mob.x) <= 3 then
        return true
    end

    if math.abs(self.y - mob.y) <= 3 then
        return true
    end

    return false
end

function Block:healthPercent()
    return self.health / self.maxhealth
end
