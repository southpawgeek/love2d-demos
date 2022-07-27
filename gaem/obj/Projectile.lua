Projectile = Class{}

function Projectile:init(x, y, speed)
   print('pew pew')
   self.x = x
   self.y = y
   self.size = 5
   self.dx = math.random(-speed, speed)
   self.dy = math.random(-speed, speed)
   self.life = 1
   self.dead = false
   self.r = math.random(0, 50) / 100
   self.g = math.random(0, 50) / 100
   self.b = 1
   self.a = 1
end

function Projectile:render()
   love.graphics.setColor(self.r, self.g, self.b, self.a)
   love.graphics.rectangle('fill', self.x, self.y, self.size, self.size)
end

function Projectile:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    self.life = self.life - dt

    if self.life < 0 then
        self:shrink(dt)
    end

    if self.size < 0 then
        self.dead = true
    end
end

function Projectile:shrink(dt)
    self.size = self.size - dt * 5
    self.a = self.a - dt
end