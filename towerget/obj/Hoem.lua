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
    do
        local function tryLoad(path)
            local ok, src = pcall(function()
                return love.audio.newSource(path, 'static')
            end)
            if ok then return src end
            return nil
        end

        self._hitHurtSource = tryLoad('towerget/sfx/hitHurt.wav') or tryLoad('sfx/hitHurt.wav')
    end

    print('init Hoem: ' .. self.x .. '/' .. self.y .. ' ' .. self.health .. 'hp')
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

function Hoem:render()
    local ratio = self:healthCalculate()
    love.graphics.setColor(1, ratio, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(LOC.S_HP .. self.health, 0, 0)
    love.graphics.print(LOC.S_XP .. self.score, 0, 15)
end

function Hoem:healthCalculate()
    if self.health < 0 then self.alive = false end
    return self.health / self.maxhealth
end
