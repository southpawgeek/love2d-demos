PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.asteroidTimer = 0
    self.asteroids = {}
    self.player1 = Player(64, 130, 'w', 's', 'P1')
    self.player2 = Player(192, 130, 'i', 'k', 'P2')
    self.winTimer = 0
end

function PlayState:update(dt)
    self.asteroidTimer = self.asteroidTimer + dt

    if self.player1.won or self.player2.won then
        self.winTimer = self.winTimer + dt 
    end

    if self.player1.score == 5 then
        self.player1.won = true
    end

    if self.player2.score == 5 then
        self.player2.won = true
    end

    if self.winTimer > 5 then
        gStateMachine:change('title')
    end

    if self.asteroidTimer > 0.2 then

        size = math.random(1, 4)

        table.insert(self.asteroids, Asteroid(size))

        self.asteroidTimer = 0
    end

    for k, asteroid in pairs(self.asteroids) do
        if asteroid.x < 0 or asteroid.x > VIRTUAL_WIDTH then
            table.remove(self.asteroids, k)

        elseif asteroid:collides(self.player1) then
            sounds['boom']:play()
            table.remove(self.asteroids, k)
            self.player1:reset()

        elseif asteroid:collides(self.player2) then
            sounds['boom']:play()
            table.remove(self.asteroids, k)
            self.player2:reset()
        else
        asteroid:update(dt)
        end
    end

    if self.player1.y == 0 then
        sounds['yay']:play()
        self.player1.score = self.player1.score + 1
        self.player1:reset()
    end

    if self.player2.y == 0 then
        sounds['yay']:play()
        self.player2.score = self.player2.score + 1
        self.player2:reset()
    end

    self.player1:update(dt)
    self.player2:update(dt)
end

function PlayState:render()
    for k, asteroid in pairs(self.asteroids) do
        asteroid:render()
    end
    self.player1:render()
    self.player2:render()
end

function PlayState:enter()
end

function PlayState:exit()
end