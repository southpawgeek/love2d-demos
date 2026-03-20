BlockTypes = {
    -- First slot: homing tower — fires once per second at nearest mob in range, else random.
    ['basic'] = {
        name = 'Basic',
        size = 3,
        footprint = 3,
        color = {0.55, 0.95, 1, 1},
        maxhealth = 10,
        health = 10,
        points = 5,
        speed = 1.0, -- fire interval (seconds); 1 shot per second
        homing = true,
        homingRadius = 100, -- virtual pixels from block center
        homingTurnRate = 9,
        projectileDuration = 1.4,
        projectileSpeed = 32,
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

--- @param cx number block center x
--- @param cy number block center y
--- @param mobs table mob list (mob.x, mob.y = center)
--- @param radius number max distance to target
--- @return Mob|nil
function Block.findClosestMobInRange(cx, cy, mobs, radius)
    if not mobs then return nil end
    local r2 = radius * radius
    local best, bestD2 = nil, nil
    for _, mob in pairs(mobs) do
        if mob.alive then
            local dx = mob.x - cx
            local dy = mob.y - cy
            local d2 = dx * dx + dy * dy
            if d2 <= r2 then
                if best == nil or d2 < bestD2 then
                    best = mob
                    bestD2 = d2
                end
            end
        end
    end
    return best
end

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
    love.graphics.rectangle('fill', self.x - self.config.size / 2, self.y - self.config.size / 2, self.config.size, self.config.size)

    -- render all child projectiles
    for k, projectile in pairs(self.projectiles) do
        projectile:render()
    end
end

function Block:update(dt, mobs)
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
        local angle = math.random() * math.pi * 2
        local cfg = self.config
        local opts = nil

        if cfg.homing then
            local radius = cfg.homingRadius or 100
            local target = Block.findClosestMobInRange(self.x, self.y, mobs, radius)
            if target then
                angle = math.atan2(target.y - self.y, target.x - self.x)
            end
            opts = {
                homing = true,
                targetMob = target,
                turnRate = cfg.homingTurnRate or 7,
                duration = cfg.projectileDuration or 1.2,
                speed = cfg.projectileSpeed or 30,
            }
        end

        table.insert(self.projectiles, Projectile(self.x, self.y, angle, opts))
        self.fire = 0
    end
end

function Block:collides(mob)
    -- 2D AABB overlap between:
    --  - this block's size-based footprint centered at (self.x, self.y)
    --  - the mob's size-based square centered at (mob.x, mob.y)
    local blockLeft = self.x - self.config.size / 2
    local blockRight = self.x + self.config.size / 2
    local blockTop = self.y - self.config.size / 2
    local blockBottom = self.y + self.config.size / 2
    local mobLeft = mob.x - mob.size / 2
    local mobRight = mob.x + mob.size / 2
    local mobTop = mob.y - mob.size / 2
    local mobBottom = mob.y + mob.size / 2

    if blockRight < mobLeft or mobRight < blockLeft then
        return false
    end
    if blockBottom < mobTop or mobBottom < blockTop then
        return false
    end

    return true
end

function Block:healthPercent()
    return self.health / self.maxhealth
end
