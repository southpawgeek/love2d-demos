Play = Class { __includes = BaseState }
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
    self.hoem = Hoem()
    self.hoemHud = HoemHud(self.hoem)

    -- The currently placeable block type (forward-compatible with future types).
    self.activeBlockClass = Block

    self.mobTimer = 0
    self.mobSpawn = 1 -- interval for mob spawning
    self.mobMax = 5
    self.mobs = {}
    self.blocks = {}
    self.pause = false

    -- Configurable world-only screen shake.
    -- Trigger via `self:triggerShake(power)` when the core takes damage.
    self.shakeCfg = {
        enabled = true,
        hitPower = 6, -- strength added per hit (clamped by maxOffset)
        maxOffset = 10, -- maximum translation in virtual pixels
        decay = 10, -- exponential decay rate (higher = shorter shake)
        frequency = 25, -- oscillation frequency (per second)
        yScale = 0.6, -- vertical wobble multiplier
    }
    self.shakeStrength = 0
    self.shakePhase = 0
end

function Play:render()
    -- HUD stays steady (world shake is applied only to the world draw).
    self.hoemHud:render()

    local dx, dy = self:getShakeOffset()
    if dx ~= 0 or dy ~= 0 then
        love.graphics.push()
        love.graphics.translate(dx, dy)
    end

    self.hoem:renderCore()

    for k, mob in pairs(self.mobs) do
        mob:render()
    end

    for k, block in pairs(self.blocks) do
        block:render()
    end

    -- Ghost placement indicator (shows where the current block would be placed).
    do
        local mx, my = Push:toGame(love.mouse.getPosition())
        if mx == nil or my == nil then
            -- Fallback for any LOVE/mouse coordinate quirks.
            mx, my = Push:toGame(love.mouse.getX(), love.mouse.getY())
        end

        if mx ~= nil and my ~= nil then
            -- Make the ghost easy to see: translucent fill + bright outline.
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0, 1, 1, 0.25)
            love.graphics.rectangle('fill', mx, my, 3, 3)
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle('line', mx, my, 3, 3)
            love.graphics.setLineWidth(1)
        end
    end

    if dx ~= 0 or dy ~= 0 then
        love.graphics.pop()
    end

    if self.pause then
        local text_width = love.graphics.getFont():getWidth(LOC.S_PAUSE)
        love.graphics.print(LOC.S_PAUSE, VIRTUAL_WIDTH - text_width, 0)
        return
    end
end

function Play:triggerShake(power)
    if not self.shakeCfg.enabled then return end
    power = power or self.shakeCfg.hitPower or 1
    self.shakeStrength = math.min(self.shakeCfg.maxOffset, (self.shakeStrength or 0) + power)
end

function Play:updateShake(dt)
    local s = self.shakeStrength or 0
    if s <= 0 then return end

    -- Advance phase for a smooth oscillation.
    local twopi = math.pi * 2
    self.shakePhase = self.shakePhase + dt * self.shakeCfg.frequency * twopi

    -- Exponential decay so shake feels consistent across frame rates.
    local decayFactor = math.exp(-self.shakeCfg.decay * dt)
    self.shakeStrength = s * decayFactor
    if self.shakeStrength < 0.01 then self.shakeStrength = 0 end
end

function Play:getShakeOffset()
    local s = self.shakeStrength or 0
    if s <= 0 then return 0, 0 end

    -- Two-axis wobble, tuned to feel "impact-ish" rather than purely circular.
    local dx = math.sin(self.shakePhase) * s
    local dy = math.cos(self.shakePhase * 1.37) * s * (self.shakeCfg.yScale or 1)
    return dx, dy
end

function Play:update(dt)
    -- esc to go back to title
    if love.keyboard.wasPressed('escape') then
        self.pause = not self.pause
    end

    if self.pause then
        return
    end

    self:updateShake(dt)

    if self.hoem.health < 0 then
        Screen:change('GameOver')
    end

    -- mouseclick to spawn block
    local click = love.mouse.wasPressed(1)

    if click then
        table.insert(self.blocks, Block(click.x, click.y))
    end

    self.mobTimer = self.mobTimer + dt
    if self.mobTimer > self.mobSpawn then
        -- spawn up to x mobs per timer
        local mob_number = math.random(self.mobMax)
        local mobTypes = { 'normal', 'squirrelly', 'zoomer' }
        for i = 1, mob_number do
            -- target destination is set on spawn
            local mobType = mobTypes[math.random(#mobTypes)]
            table.insert(self.mobs, Mob(self.hoem.x, self.hoem.y, mobType))
        end

        self.mobTimer = 0
    end

    -- remove dead blocks
    for k, block in pairs(self.blocks) do
        if block.health < 1 then
            block:exit()
            --self.hoem.score = self.hoem.score + block.points
            table.remove(self.blocks, k)
        end

        -- Advance projectiles for this frame before collision checks, so what you see
        -- aligns with the projectile positions used for hits.
        block:update(dt)

        -- checks for mobs hitting blocks
        for j, mob in pairs(self.mobs) do
            if block:collides(mob) then
                block.health = block.health - 1
                mob:exit()
            end
            -- checks for block projectiles hitting mobs
            for l, projectile in pairs(block.projectiles) do
                if projectile:collides(mob) then
                    print('killed a mob')
                    self.hoem.score = self.hoem.score + 1
                    mob:exit()
                end
            end
        end
    end

    -- checks for damage to the core
    for k, mob in pairs(self.mobs) do
        if mob:collides(self.hoem) then
            self.hoem:takeDamage(1)
            self:triggerShake(self.shakeCfg.hitPower)
            mob:exit()
        end

        if mob.alive then
            mob:update(dt)
        else
            table.remove(self.mobs, k)
        end
    end
end
