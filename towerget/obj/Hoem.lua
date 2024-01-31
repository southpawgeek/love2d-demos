Hoem = Class {}

function Hoem:init()
    self.x = VIRTUAL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2
    self.maxhealth = 25
    self.health = 25
    self.size = 10
    self.score = 0
    self.alive = true
    print('init Hoem: ' .. self.x .. '/' .. self.y .. ' ' .. self.health .. 'hp')
end

function Hoem:render()
    local ratio = self:healthCalculate()
    love.graphics.setColor(1, ratio, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('hp: ' .. self.health, 0, 0)
    love.graphics.print('xp: ' .. self.score, 0, 15)
end

function Hoem:healthCalculate()
    if self.health < 0 then self.alive = false end
    return self.health / self.maxhealth
end
