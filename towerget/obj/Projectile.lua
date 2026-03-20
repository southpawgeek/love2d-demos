Projectile = Class {}

function Projectile:init(x, y, angle, opts)
    opts = opts or {}
    self.x, self.y = x, y
    self.angle = angle
    self.speed = opts.speed or 30
    self.size = 2
    self.duration = opts.duration or 0.5
    self.alive = true
    self.homing = opts.homing or false
    self.targetMob = opts.targetMob
    self.turnRate = opts.turnRate or 7 -- radians per second toward target
    --print('init Projectile: ' .. self.x .. '/' .. self.y .. ' angle: ' .. self.angle)
end

function Projectile:exit()
    self.alive = false
    --print('projectile dead')
end

function Projectile:render()
    if self.homing then
        love.graphics.setColor(0.4, 1, 1, 1)
    else
        love.graphics.setColor(1, 0, 1, 1)
    end
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
        -- Mob x,y is the center of the hitbox (matches Block/Projectile collides).
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
