Player = Class{}

function Player:init(x, y, up, down, name)
    self.x = x
    self.y = y
    self.width = 5
    self.height = 10
    self.dy = 0
    self.speed = 100
    self.score = 0

    self.up = up
    self.down = down
    self.name = name

    self.won = false
end

function Player:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end

    if love.keyboard.isDown(self.up) then
        self.dy = -self.speed
    elseif love.keyboard.isDown(self.down) then
        self.dy = self.speed
    else
        self.dy = 0
    end
end

function Player:reset()
    self.y = 130
end

function Player:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', self.x, self.y, self.width, 3)
    love.graphics.rectangle('fill', self.x, self.y + 8, 2, 2)
    love.graphics.rectangle('fill', self.x + self.width - 2, self.y + 8, 2, 2)
    love.graphics.setColor(0, 0.7, 1, 1)
    love.graphics.rectangle('fill', self.x + 1, self.y + 4, 3, 3)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.points(
        self.x + 0.5, self.y + 0.5, 
        self.x + self.width - 1 + 0.5, self.y + 0.5, 
        self.x + self.width / 2 - 0.5, self.y + self.height - 0.5
    )
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(tinyFont)
    love.graphics.print(self.score, self.x - 30, 130)
    love.graphics.print(string.upper(self.up) .. ' / ' .. string.upper(self.down), self.x + 30, 130)

    if self.won then
        love.graphics.print("YOU WON!", self.x - 20, VIRTUAL_HEIGHT / 2)
    end
end