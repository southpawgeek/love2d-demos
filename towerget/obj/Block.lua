Block = Class{}

function Block:init(x, y)
   self.x = x
   self.y = y

   self.maxhealth = 10
   self.health = 10
   print('init block: ' .. self.x .. '/' .. self.y)
end

function Block:exit()
   print('block dead')
end

function Block:render()
    ratio = self:healthPercent()
   love.graphics.setColor(0, ratio, ratio, 1)
   love.graphics.rectangle('fill', self.x, self.y, 3, 3)
end

function Block:update(dt)
end

function Block:collides(mob)
    if math.abs(self.x - mob.x) <= 3 then
        return true
    end

    if math.abs(self.y - mob.y) <= 3 then
        return true
    end

    return false
end

function Block:healthPercent()
    return self.health / self.maxhealth
end