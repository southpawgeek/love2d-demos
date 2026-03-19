HoemHud = Class {}

function HoemHud:init(hoem)
    self.hoem = hoem
end

function HoemHud:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(LOC.S_HP .. self.hoem.health, 0, 0)
    love.graphics.print(LOC.S_XP .. self.hoem.score, 0, 15)
end

