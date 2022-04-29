Building = Class{}

function Building:init()
    self.type = 'Building'
    self.level = 0
    self.exp = 0
    self.x = 0
    self.y = 0
    self.size = 10
end

function Building:render()
    love.graphics.rectangle('line', self.x, self.y, self.size, self.size)
end