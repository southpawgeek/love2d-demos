--- Projectile behavior presets (merged with per-block overrides in BlockTypes).
ProjectileTypes = {
    --- Straight shot, random direction each fire (e.g. large tower “particles”).
    ['radiate'] = {
        name = 'Radiate',
        size = 2,
        speed = 30,
        duration = 0.5,
        homing = false,
        color = { 1, 0, 1, 1 },
        projectiles = true,
    },
    --- Seeks nearest mob in range, else initial angle (basic tower).
    ['homing'] = {
        name = 'Homing',
        size = 2,
        speed = 32,
        duration = 1.4,
        homing = true,
        homingRadius = 100,
        turnRate = 9,
        color = { 0.4, 1, 1, 1 },
        projectiles = true,
    },
    --- No bullets; AoE pulse ring on the block (medium / zapper).
    ['zapper'] = {
        name = 'Zapper',
        projectiles = false,
        pulseInterval = 1.0,
        pulseFadeDuration = 0.5,
        pulseRadius = 25,
        pulseFillAlpha = 0.32,
    },
}

Projectile = Class {}

--- Block-only keys in BlockTypes: must not overwrite projectile stats when merging.
--- (e.g. block `speed` is fire interval seconds, not pixels/sec for bullets.)
local BLOCK_ONLY_MERGE_KEYS = {
    speed = true,
    size = true,
    footprint = true,
    color = true,
    name = true,
    maxhealth = true,
    health = true,
    points = true,
    projectileType = true,
}

--- Shallow merge: ProjectileTypes[type] defaults, then blockCfg overrides (block wins).
--- @param blockCfg table BlockTypes entry (expects optional projectileType string)
--- @return table
function Projectile.mergedBlockProjectileConfig(blockCfg)
    blockCfg = blockCfg or {}
    local t = blockCfg.projectileType or 'radiate'
    local base = ProjectileTypes[t] or ProjectileTypes.radiate
    local m = {}
    for k, v in pairs(base) do
        m[k] = v
    end
    for k, v in pairs(blockCfg) do
        if not BLOCK_ONLY_MERGE_KEYS[k] then
            m[k] = v
        end
    end
    return m
end

function Projectile:init(x, y, angle, opts)
    opts = opts or {}
    self.x, self.y = x, y
    self.angle = angle
    self.speed = opts.speed or 30
    self.size = opts.size or 2
    self.duration = opts.duration or 0.5
    self.alive = true
    self.homing = opts.homing or false
    self.targetMob = opts.targetMob
    self.turnRate = opts.turnRate or 7
    local c = opts.color
    if c then
        self.color = { c[1], c[2], c[3], c[4] or 1 }
    else
        self.color = { 1, 0, 1, 1 }
    end
end

function Projectile:exit()
    self.alive = false
end

function Projectile:render()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4])
    love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end

local function shortestAngleDelta(from, to)
    local d = (to - from) % (math.pi * 2)
    if d > math.pi then
        d = d - math.pi * 2
    end
    return d
end

function Projectile:update(dt)
    if self.homing and self.targetMob and self.targetMob.alive then
        local mx, my = self.targetMob.x, self.targetMob.y
        local desired = math.atan2(my - self.y, mx - self.x)
        local diff = shortestAngleDelta(self.angle, desired)
        local maxStep = self.turnRate * dt
        if diff > maxStep then
            diff = maxStep
        elseif diff < -maxStep then
            diff = -maxStep
        end
        self.angle = self.angle + diff
    end

    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt

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
