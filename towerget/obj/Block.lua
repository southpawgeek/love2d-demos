BlockTypes = {
    -- First slot: homing tower — fires once per second at nearest mob in range, else random.
    ['basic'] = {
        name = 'Homing',
        size = 3,
        footprint = 3,
        color = { 0.55, 0.95, 1, 1 },
        maxhealth = 10,
        health = 10,
        points = 5,
        speed = 1.0,        -- fire interval (seconds); 1 shot per second
        homing = true,
        homingRadius = 100, -- virtual pixels from block center
        homingTurnRate = 9,
        projectileDuration = 1.4,
        projectileSpeed = 32,
    },
    ['medium'] = {
        name = 'Zapper',
        size = 5,
        footprint = 5,
        color = { 1, 1, 1, 1 },
        maxhealth = 15,
        health = 15,
        points = 8,
        speed = 0.15,            -- unused while projectiles disabled; kept for tuning if re-enabled
        projectiles = false,     -- pulse only; no projectile emission
        -- Magenta pulse AoE (damages mobs in radius once per pulse)
        pulseInterval = 1.0,     -- seconds between pulses
        pulseFadeDuration = 0.5, -- ring appears at full opacity, then fades out over this time
        pulseRadius = 25,        -- virtual pixels from block center
    },
    ['large'] = {
        name = 'Large',
        size = 9,
        footprint = 9,
        color = { 1, 1, 1, 1 },
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

--- Kill all alive mobs whose center lies within radius of (cx, cy). Calls ctx.onMobKill() per kill if set.
function Block.damageMobsInRadius(cx, cy, radius, mobs, ctx)
    if not mobs or not radius or radius <= 0 then return end
    ctx = ctx or {}
    local r2 = radius * radius
    for _, mob in pairs(mobs) do
        if mob.alive then
            local dx = mob.x - cx
            local dy = mob.y - cy
            if dx * dx + dy * dy <= r2 then
                mob:exit()
                if ctx.onMobKill then
                    ctx.onMobKill()
                end
            end
        end
    end
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
    self.pulseTimer = 0
    self.pulseRingLeft = 0 -- >0 while magenta ring is drawn
end

function Block:exit()
    --print('block dead')
end

function Block:render()
    local ratio = self:healthPercent()
    love.graphics.setColor(self.config.color[1], self.config.color[2], self.config.color[3], self.config.color[4] * ratio)
    love.graphics.rectangle('fill', self.x - self.config.size / 2, self.y - self.config.size / 2, self.config.size,
        self.config.size)

    -- render all child projectiles
    for k, projectile in pairs(self.projectiles) do
        projectile:render()
    end

    -- Pulse AoE ring (e.g. medium): pops in, fades out over pulseFadeDuration
    if self.pulseRingLeft and self.pulseRingLeft > 0 then
        local cfg = self.config
        local pr = cfg.pulseRadius or 25
        local fade = cfg.pulseFadeDuration or 0.5
        if fade <= 0 then fade = 0.001 end
        -- p: 1 at pulse start (white), 0 at end (magenta); alpha follows same curve
        local p = math.min(1, self.pulseRingLeft / fade)
        local r, g, b = 1, p, 1
        love.graphics.setColor(r, g, b, 0.32 * p)
        love.graphics.circle('fill', self.x, self.y, pr)
        love.graphics.setColor(r, g, b, p)
        love.graphics.setLineWidth(1)
        love.graphics.circle('line', self.x, self.y, pr)
        love.graphics.setLineWidth(1)
    end
end

function Block:update(dt, mobs, ctx)
    ctx = ctx or {}
    -- remove dead projectiles
    for k, projectile in pairs(self.projectiles) do
        projectile:update(dt)
        if projectile.alive == false then
            table.remove(self.projectiles, k)
        end
    end

    local cfg = self.config
    if cfg.pulseInterval and cfg.pulseInterval > 0 then
        self.pulseTimer = self.pulseTimer + dt
        if self.pulseTimer >= cfg.pulseInterval then
            self.pulseTimer = 0
            self.pulseRingLeft = cfg.pulseFadeDuration or 0.5
            Block.damageMobsInRadius(self.x, self.y, cfg.pulseRadius or 25, mobs, ctx)
        end
    end
    if self.pulseRingLeft and self.pulseRingLeft > 0 then
        self.pulseRingLeft = math.max(0, self.pulseRingLeft - dt)
    end

    -- fire new projectile (medium: projectiles = false, circle only)
    if cfg.projectiles ~= false then
        self.fire = self.fire + dt
        if self.fire >= self.speed then
            local angle = math.random() * math.pi * 2
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
    else
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
