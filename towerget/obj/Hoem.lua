Hoem = Class{}

function Hoem:init()
   self.x = VIRTUAL_WIDTH / 2
   self.y = VIRTUAL_HEIGHT / 2
   self.maxhealth = 100
   self.health = 100
   self.size = 10
   print('init Hoem: ' .. self.x .. '/' .. self.y .. ' ' .. self.health .. 'hp')
end

function Hoem:render()
    ratio = self:healthPercent()
   love.graphics.setColor(1, ratio, ratio, 1)
   love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.print(self.health .. 'hp', 0, 0)
end

function Hoem:healthPercent()
    return self.health / self.maxhealth
end