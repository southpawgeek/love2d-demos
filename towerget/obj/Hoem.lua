Hoem = Class {}

function Hoem:init()
    self.x = VIRTUAL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2
    self.maxhealth = 25
    self.health = 25
    self.size = 10
    self.score = 0
    self.alive = true
    self._hitHurtCount = 0

    -- Load once and reuse; we'll only tweak pitch per hit.
    -- Path varies depending on where `love` is launched from, so we try a couple options.
    self._hitHurtSource = nil
    self._pickupCoinPool = {}
    self._pickupPoolIndex = 0
    self._powerUpSource = nil
    do
        local function tryLoad(path)
            local ok, src = pcall(function()
                return love.audio.newSource(path, 'static')
            end)
            if ok then return src end
            return nil
        end

        self._hitHurtSource = tryLoad('towerget/sfx/hitHurt.wav') or tryLoad('sfx/hitHurt.wav')

        local cfg = TUNING.xpPickup or {}
        local n = cfg.poolCount or 14
        local vol = cfg.volume or 0.28
        for _ = 1, n do
            local s = tryLoad('towerget/sfx/pickupCoin.wav') or tryLoad('sfx/pickupCoin.wav')
            if s then
                s:setVolume(vol)
                table.insert(self._pickupCoinPool, s)
            end
        end

        self._powerUpSource = tryLoad('towerget/sfx/powerUp.wav') or tryLoad('sfx/powerUp.wav')
    end

    print('init Hoem: ' .. self.x .. '/' .. self.y .. ' ' .. self.health .. 'hp')
end

function Hoem:_xpPickupRateAllowed(cfg)
    local cap = cfg.maxStartsPerSecond
    if not cap or cap <= 0 then
        return true
    end
    local now = love.timer.getTime()
    self._xpPickupStartTimes = self._xpPickupStartTimes or {}
    local times = self._xpPickupStartTimes
    local i = 1
    while i <= #times do
        if now - times[i] > 1.0 then
            table.remove(times, i)
        else
            i = i + 1
        end
    end
    return #times < cap
end

function Hoem:_xpPickupRecordStart(cfg)
    local cap = cfg.maxStartsPerSecond
    if not cap or cap <= 0 then
        return
    end
    self._xpPickupStartTimes = self._xpPickupStartTimes or {}
    table.insert(self._xpPickupStartTimes, love.timer.getTime())
end

function Hoem:playXpPickup(progress)
    if not self._pickupCoinPool or #self._pickupCoinPool == 0 then
        return
    end

    local cfg = TUNING.xpPickup or {}

    if not self:_xpPickupRateAllowed(cfg) then
        return
    end

    if cfg.minInterval and cfg.minInterval > 0 then
        local now = love.timer.getTime()
        if now - (self._lastXpPickupTime or 0) < cfg.minInterval then
            return
        end
        self._lastXpPickupTime = now
    end

    local p = progress or 0
    if p < 0 then p = 0 end
    if p > 1 then p = 1 end

    -- Pitch ramps up toward next level (1.0 -> 2.0), resets when level advances.
    local pitch = 1.0 + p

    local pool = self._pickupCoinPool
    local n = #pool
    local start = self._pickupPoolIndex

    -- Use an idle voice when possible: true overlap, no stop() click.
    for i = 1, n do
        local idx = ((start + i - 1) % n) + 1
        local src = pool[idx]
        if not src:isPlaying() then
            self._pickupPoolIndex = idx
            src:setPitch(pitch)
            src:play()
            self:_xpPickupRecordStart(cfg)
            return
        end
    end

    -- All voices busy
    if (cfg.onPoolExhausted or 'skip') == 'steal' then
        self._pickupPoolIndex = (self._pickupPoolIndex % n) + 1
        local src = pool[self._pickupPoolIndex]
        src:stop()
        src:setPitch(pitch)
        src:play()
        self:_xpPickupRecordStart(cfg)
    end
    -- 'skip': no more than poolCount overlapping; extra kills stay silent
end

function Hoem:playLevelUp()
    if not self._powerUpSource then
        return
    end
    self._powerUpSource:stop()
    self._powerUpSource:setPitch(1)
    self._powerUpSource:play()
end

function Hoem:takeDamage(amount)
    amount = amount or 1
    self.health = self.health - amount

    self._hitHurtCount = (self._hitHurtCount or 0) + 1
    if self._hitHurtSource then
        -- Pitch varies by +/-20% each time.
        local pitch = 1 + (math.random() * 0.4 - 0.2)
        self._hitHurtSource:setPitch(pitch)

        -- `stop()` helps ensure the new pitch applies immediately.
        self._hitHurtSource:stop()
        self._hitHurtSource:play()
    end
end

function Hoem:renderCore()
    local ratio = self:healthCalculate()
    local halfSize = self.size / 2
    love.graphics.setColor(1, ratio, 0, 1)
    love.graphics.rectangle('fill', self.x - halfSize, self.y - halfSize, self.size, self.size)
end

function Hoem:renderHud()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(LOC.S_HP .. self.health, 0, 0)
    love.graphics.print(LOC.S_XP .. self.score, 0, 15)
end

function Hoem:render()
    -- Back-compat: render both core and HUD text.
    self:renderCore()
    self:renderHud()
end

function Hoem:healthCalculate()
    if self.health < 0 then self.alive = false end
    return self.health / self.maxhealth
end
