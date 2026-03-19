BlockTypes = {
    ['basic'] = {
        name = 'Basic',
        size = 3,
        footprint = 3,
        color = {1, 1, 1, 1},
        maxhealth = 10,
        health = 10,
        points = 5,
        speed = 0.2,
    },
    ['medium'] = {
        name = 'Medium',
        size = 5,
        footprint = 5,
        color = {1, 1, 1, 1},
        maxhealth = 15,
        health = 15,
        points = 8,
        speed = 0.15,
    },
    ['large'] = {
        name = 'Large',
        size = 9,
        footprint = 9,
        color = {1, 1, 1, 1},
        maxhealth = 25,
        health = 25,
        points = 12,
        speed = 0.1,
    },
}

Block = Class {}

function Block:init(x, y, variant)
    self.x = x
    self.y = y

    local config = BlockTypes[variant or 'basic']
    self.config = config
    self.variant = variant or 'basic'

    self.maxhealth = config.maxhealth
    self.health = config.health
    self.points = config.points
    self.projectiles = {}
    self.fire = 0
    self.speed = config.speed
end

function Block:exit()
    --print('block dead')
end

function Block:render()
    local ratio = self:healthPercent()
    love.graphics.setColor(self.config.color[1], self.config.color[2], self.config.color[3], self.config.color[4] * ratio)
    love.graphics.rectangle('fill', self.x, self.y, self.config.size, self.config.size)

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
    -- 2D AABB overlap between:
    --  - this block's size-based footprint at (self.x, self.y)
    --  - the mob's size-based square at (mob.x, mob.y)
    if self.x > mob.x + mob.size or mob.x > self.x + self.config.size then
        return false
    end

    if self.y > mob.y + mob.size or mob.y > self.y + self.config.size then
        return false
    end

    return true
end

function Block:healthPercent()
    return self.health / self.maxhealth
end
