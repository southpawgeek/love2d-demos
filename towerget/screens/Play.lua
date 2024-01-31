Play = Class { __includes = BaseState }
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
    self.hoem = Hoem()
    self.mobTimer = 0
    self.mobSpawn = 1 -- interval for mob spawning
    self.mobMax = 5
    self.mobs = {}
    self.blocks = {}
    self.pause = false
end

function Play:render()
    self.hoem:render()

    for k, mob in pairs(self.mobs) do
        mob:render()
    end

    for k, block in pairs(self.blocks) do
        block:render()
    end

    if self.pause then
        local pause = 'PAUSE'
        local text_width = love.graphics.getFont():getWidth(pause)
        love.graphics.print(pause, VIRTUAL_WIDTH - text_width, 0)
        return
    end
end

function Play:update(dt)
    -- esc to go back to title
    if love.keyboard.wasPressed('escape') then
        self.pause = not self.pause
    end

    if self.pause then
        return
    end

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
        for i = 1, mob_number do
            -- target destination is set on spawn
            table.insert(self.mobs, Mob(self.hoem.x, self.hoem.y))
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

        block:update(dt)
    end

    -- checks for damage to the core
    for k, mob in pairs(self.mobs) do
        if mob:collides(self.hoem) then
            self.hoem.health = self.hoem.health - 1
            mob:exit()
        end

        if mob.alive then
            mob:update(dt)
        else
            table.remove(self.mobs, k)
        end
    end
end
