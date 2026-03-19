Mob = Class {}

local MobTypes = {
    normal = {
        color = {1, 1, 1, 1},
        shape = 'rect',
        speedMin = 10,
        speedMax = 50,
        sizeMin = 3,
        sizeMax = 9
    },
    squirrelly = {
        color = {1, 0.75, 0.85, 1}, -- light pink
        shape = 'tri',
        speedMin = 8,
        speedMax = 30,
        sizeMin = 4,
        sizeMax = 10,
        swirlAmp1 = 0.65, -- radians wobble component
        swirlFreq1 = 4.0,
        swirlAmp2 = 0.35,
        swirlFreq2 = 9.0
    },
    zoomer = {
        color = {0.65, 0.9, 1, 1}, -- light blue
        shape = 'diamond',
        speedMin = 25,
        speedMax = 90,
        sizeMin = 3,
        sizeMax = 7,
        zigAngle = 0.95, -- radians offset from base angle
        zigIntervalMin = 0.05,
        zigIntervalMax = 0.18
    },
    bouncy = {
        color = {1, 1, 0.7, 1}, -- light yellow
        shape = 'circle',
        speedMin = 18,
        speedMax = 55,
        sizeMin = 4,
        sizeMax = 10,

        -- "Bounces": oscillate toward/away along the radial-to-core direction.
        bounceFreq = 4.0, -- bounces per second
        forwardBias = 0.35, -- baseline forward push (keeps average movement toward core)
        awayAmp = 0.95, -- amplitude of away oscillation (will be faded out near the core)

        -- "Circular": add tangential motion so the path arcs around the core.
        orbitAmp = 0.8,
        orbitFreqMul = 1.25,
        fadeDist = 110 -- when close to core, reduce away so it converges
    }
}

function Mob:init(x, y, mobType)
    self.x, self.y = self:getSpawnPoint()
    self.destx, self.desty = x, y
    self.mobType = mobType or 'normal'

    local cfg = MobTypes[self.mobType] or MobTypes.normal

    self.speed = math.random(cfg.speedMin, cfg.speedMax)
    self.size = math.random(cfg.sizeMin, cfg.sizeMax)
    self.alive = true
    self.color = cfg.color
    self.shape = cfg.shape

    self.t = 0 -- type-specific time accumulator
    self.moveAngle = math.atan2(self.desty - self.y, self.destx - self.x)

    if self.mobType == 'squirrelly' then
        self.swirlPhase1 = math.random() * math.pi * 2
        self.swirlPhase2 = math.random() * math.pi * 2
        self.swirlAmp1 = cfg.swirlAmp1
        self.swirlFreq1 = cfg.swirlFreq1
        self.swirlAmp2 = cfg.swirlAmp2
        self.swirlFreq2 = cfg.swirlFreq2
    elseif self.mobType == 'zoomer' then
        self.zigTimer = 0
        self.zigDir = math.random(0, 1) == 0 and -1 or 1
        self.zigAngle = cfg.zigAngle
        self.zigIntervalMin = cfg.zigIntervalMin
        self.zigIntervalMax = cfg.zigIntervalMax
    elseif self.mobType == 'bouncy' then
        self.bouncePhase = math.random() * math.pi * 2
        self.orbitPhase = math.random() * math.pi * 2
    end

    print('init mob: ' .. self.x .. '/' .. self.y)
end

function Mob:exit()
    self.alive = false
    --print('mob dead')
end

function Mob:render()
    local r = self.size
    local cx, cy = self.x + r / 2, self.y + r / 2

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)

    if self.shape == 'rect' then
        love.graphics.rectangle('fill', self.x, self.y, r, r)
        return
    end

    if self.shape == 'tri' then
        -- Triangle oriented along moveAngle.
        local a = self.moveAngle or 0
        local rad = r / 2
        local pts = {}
        for i = 0, 2 do
            local ang = a + i * 2 * math.pi / 3
            table.insert(pts, cx + math.cos(ang) * rad)
            table.insert(pts, cy + math.sin(ang) * rad)
        end
        love.graphics.polygon('fill', pts)
        return
    end

    if self.shape == 'diamond' then
        -- Diamond (rotated square) oriented along moveAngle.
        local a = self.moveAngle or 0
        local rad = r / 2
        local pts = {}
        for i = 0, 3 do
            local ang = a + math.pi / 4 + i * math.pi / 2
            table.insert(pts, cx + math.cos(ang) * rad)
            table.insert(pts, cy + math.sin(ang) * rad)
        end
        love.graphics.polygon('fill', pts)
        return
    end

    if self.shape == 'circle' then
        local r = self.size
        local radius = r / 2
        local cx, cy = self.x + radius, self.y + radius
        love.graphics.circle('fill', cx, cy, radius)
        return
    end
end

function Mob:update(dt)
    self.t = (self.t or 0) + dt

    local dxToCore = (self.destx - self.x)
    local dyToCore = (self.desty - self.y)
    local distToCore = math.sqrt(dxToCore * dxToCore + dyToCore * dyToCore)

    local baseAngle = math.atan2(dyToCore, dxToCore)
    local angle = baseAngle

    if self.mobType == 'squirrelly' then
        -- Erratic swirly wobble while still progressing toward the core.
        local wobble1 = math.sin(self.t * self.swirlFreq1 + self.swirlPhase1) * self.swirlAmp1
        local wobble2 = math.sin(self.t * self.swirlFreq2 + self.swirlPhase2) * self.swirlAmp2
        angle = baseAngle + wobble1 + wobble2

    elseif self.mobType == 'zoomer' then
        -- Very fast zig-zag: periodically flip zig direction and keep heading for the core.
        self.zigTimer = (self.zigTimer or 0) - dt
        if self.zigTimer <= 0 then
            self.zigTimer = math.random() * (self.zigIntervalMax - self.zigIntervalMin) + self.zigIntervalMin
            self.zigDir = math.random(0, 1) == 0 and -1 or 1
            -- Slightly randomize the zig angle each toggle for "chaotic".
            local jitter = 0.75 + math.random() * 0.5 -- 0.75..1.25
            self.zigAngle = (self.zigAngle or 0.95) * jitter
        end

        angle = baseAngle + (self.zigDir or 1) * (self.zigAngle or 0.95)

    elseif self.mobType == 'bouncy' then
        local cfg = MobTypes[self.mobType] or MobTypes.bouncy

        -- Unit vectors pointing toward the core and perpendicular to it.
        local dist = distToCore
        if dist < 0.0001 then dist = 0.0001 end
        local ux, uy = dxToCore / dist, dyToCore / dist
        local px, py = -uy, ux

        -- Fade away oscillation as we get close to the core, so it can converge.
        local fade = math.min(1, distToCore / (cfg.fadeDist or 110))

        local phase = self.bouncePhase + (self.t * cfg.bounceFreq * math.pi * 2)
        local awayOsc = math.sin(phase) -- -1..1
        local forwardFactor = (cfg.forwardBias or 0.35) + (cfg.awayAmp or 0.95) * fade * awayOsc

        local orbitPhase = self.orbitPhase + phase * (cfg.orbitFreqMul or 1.25)
        local tangentialFactor = (cfg.orbitAmp or 0.8) * math.cos(orbitPhase)

        local vx = ux * self.speed * forwardFactor + px * self.speed * tangentialFactor
        local vy = uy * self.speed * forwardFactor + py * self.speed * tangentialFactor

        self.moveAngle = math.atan2(vy, vx)
        self.x = self.x + vx * dt
        self.y = self.y + vy * dt
        return
    end

    self.moveAngle = angle

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
