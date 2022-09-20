Play = Class{__includes = BaseState}
Play._name = 'Play'

function Play:enter()
    SCREEN = self._name
    self.hoem = Hoem()
    self.mobTimer = 0
    self.mobSpawn = 0.2
    self.mobMax = 5
    self.mobs = {}
    self.blocks = {}
end

function Play:render()
    self.hoem:render()

    for k, mob in pairs(self.mobs) do
        mob:render()
    end

    for k, block in pairs(self.blocks) do
        block:render()
    end
end

function Play:update(dt)
    -- esc to go back to title
    if love.keyboard.wasPressed('escape') then
        Screen:change('Title')
    end

    -- mouseclick to spawn block
    local p = love.mouse.wasPressed(1)

    if p then
        table.insert(self.blocks, Block(p.x, p.y))
    end

    self.mobTimer = self.mobTimer + dt
    if self.mobTimer > self.mobSpawn then
        -- spawn up to x mobs per timer
        mob_number = math.random(self.mobMax)
        for i = 1, mob_number do
            -- target destination is set on spawn
            table.insert(self.mobs, Mob(self.hoem.x, self.hoem.y))
        end

        self.mobTimer = 0
    end

    for k, block in pairs(self.blocks) do
        if block.health < 1 then
            block:exit()
            table.remove(self.blocks, k)
        end

        for j, mob in pairs(self.mobs) do
            if block:collides(mob) then
                block.health = block.health - 1
                mob:exit()
            end
        end

        block:update(dt)
    end

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