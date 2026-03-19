Play = Class { __includes = BaseState }
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
    self.hoem = Hoem()
    self.hoemHud = HoemHud(self.hoem)

    -- The currently placeable block type (forward-compatible with future types).
    self.activeBlockClass = Block
    self.activeBlockVariant = 'basic'

    -- Block variant selection state
    self.selectedBlockVariantIndex = 1  -- 1=Basic, 2=Medium, 3=Large
    self.selectedBlockVariant = BlockTypes['basic']

    -- Variant names for UI
    self.variantNames = { 'Basic', 'Medium', 'Large' }

    -- XP/level state (XP is currently `hoem.score`).
    self.level = 1
    self.levelXpStart, self.levelXpNext = TUNING:xpWindowForLevel(self.level)
    self.difficulty = TUNING:difficultyByLevel(self.level)

    self.mobTimer = 0
    self.mobSpawn = self.difficulty.mobSpawn -- interval for mob spawning
    self.mobMax = self.difficulty.mobMax
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

function Play:updateLevelFromXp()
    local xp = self.hoem.score or 0
    local newLevel = TUNING:levelForXp(xp)
    if newLevel ~= self.level then
        self.level = newLevel
        self.levelXpStart, self.levelXpNext = TUNING:xpWindowForLevel(self.level)
        self.difficulty = TUNING:difficultyByLevel(self.level)
        self.mobSpawn = self.difficulty.mobSpawn
        self.mobMax = self.difficulty.mobMax
    end

    -- Keep HUD progress updated even when level doesn't change.
    self.levelXpStart, self.levelXpNext = TUNING:xpWindowForLevel(self.level)
    self.hoemHud:setXpProgress(xp, self.levelXpStart, self.levelXpNext)
end

function Play:getLevelXpProgress(xpOverride)
    local xp = xpOverride
    if xp == nil then
        xp = self.hoem.score or 0
    end

    local level = TUNING:levelForXp(xp)
    local startXp, nextXp = TUNING:xpWindowForLevel(level)
    if not nextXp or nextXp <= startXp then
        return 0
    end

    local p = (xp - startXp) / (nextXp - startXp)
    if p < 0 then return 0 end
    if p > 1 then return 1 end
    return p
end

function Play:render()
    -- HUD stays steady (world shake is applied only to the world draw).
    self.hoemHud:render()

    -- Block variant selector UI (above XP indicator)
    self:renderBlockSelector()

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
            local variant = self.selectedBlockVariant
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0, 1, 1, 0.25)
            love.graphics.rectangle('fill', mx - variant.size / 2, my - variant.size / 2, variant.size, variant.size)
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle('line', mx - variant.size / 2, my - variant.size / 2, variant.size, variant.size)
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

function Play:renderBlockSelector()
    local blockSize = 24
    local padding = 8
    local totalWidth = (#self.variantNames * (blockSize + padding)) - padding
    local startX = (VIRTUAL_WIDTH - totalWidth) / 2
    local bottomY = VIRTUAL_HEIGHT - 60
    
    for i, variantName in ipairs(self.variantNames) do
        local variant = BlockTypes[string.lower(variantName)]
        local x = startX + (i - 1) * (blockSize + padding)
        local y = bottomY
        
        -- Draw block representation
        love.graphics.setColor(variant.color[1], variant.color[2], variant.color[3], variant.color[4])
        love.graphics.rectangle('fill', x, y, variant.size, variant.size)
        
        -- Draw selection indicator (outline)
        if self.selectedBlockVariantIndex == i then
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle('line', x, y, variant.size, variant.size)
            love.graphics.setLineWidth(1)
        end
    end
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
    self:updateLevelFromXp()

    if self.hoem.health < 0 then
        Screen:change('GameOver')
    end

    -- Block variant selection via mousewheel
    local wheel = love.mouse.getWheel()
    if wheel ~= nil and wheel ~= 0 then
        if wheel > 0 then
            -- Scroll up: cycle to previous variant
            self.selectedBlockVariantIndex = self.selectedBlockVariantIndex == 1 and 3 or self.selectedBlockVariantIndex - 1
        else
            -- Scroll down: cycle to next variant
            self.selectedBlockVariantIndex = self.selectedBlockVariantIndex == 3 and 1 or self.selectedBlockVariantIndex + 1
        end
        self.selectedBlockVariant = BlockTypes[self.variantNames[self.selectedBlockVariantIndex]:lower()]
    end
    love.mouse.totalWheel = 0

    -- Block variant selection via left/right arrows
    local left = love.keyboard.wasPressed('left') or love.keyboard.wasPressed('a')
    local right = love.keyboard.wasPressed('right') or love.keyboard.wasPressed('d')
    if left then
        self.selectedBlockVariantIndex = self.selectedBlockVariantIndex == 1 and 3 or self.selectedBlockVariantIndex - 1
        self.selectedBlockVariant = BlockTypes[self.variantNames[self.selectedBlockVariantIndex]:lower()]
    end
    if right then
        self.selectedBlockVariantIndex = self.selectedBlockVariantIndex == 3 and 1 or self.selectedBlockVariantIndex + 1
        self.selectedBlockVariant = BlockTypes[self.variantNames[self.selectedBlockVariantIndex]:lower()]
    end

    -- mouseclick to spawn block
    local click = love.mouse.wasPressed(1)

    if click then
        local variant = BlockTypes[self.variantNames[self.selectedBlockVariantIndex]:lower()]
        table.insert(self.blocks, Block(click.x, click.y, self.variantNames[self.selectedBlockVariantIndex]:lower()))
    end

    self.mobTimer = self.mobTimer + dt
    if self.mobTimer > self.mobSpawn then
        -- spawn up to x mobs per timer
        local mob_number = math.random(self.mobMax)
        local mobTypes = { 'normal', 'squirrelly', 'zoomer', 'bouncy' }
        for i = 1, mob_number do
            -- target destination is set on spawn
            local mobType = mobTypes[math.random(#mobTypes)]
            table.insert(self.mobs, Mob(self.hoem.x, self.hoem.y, mobType, self.difficulty))
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
                self.hoem:playXpPickup(self:getLevelXpProgress(self.hoem.score))
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
