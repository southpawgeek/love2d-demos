Guy = Class{}

function Guy:init()
    self.name = NamePool:get()
    self.health = 10
    self.exp = 0
    self.loc = {
        x = 0,
        y = 0
    }
    self.power = {
        class = 'Stickman',
        weapon = 'Stick',
        damage = 10,
        range = 1
    }

    print(self.name .. ' the ' .. self.power['class'] .. ' is born. He carries a ' .. self.power['weapon'] .. ' with ' .. self.power['range'] .. ' range and ' .. self.power['damage'] .. ' damage.')
end

function Guy:pickupMagic()
    self.prev = self.power['class']
    self.power = {
        class = 'Magicman',
        weapon = 'Magic Stick',
        damage = 15,
        range = 10
    }
    self:reportPickup()
end

function Guy:pickupArrows()
    self.prev = self.power['class']
    self.power = {
        class = 'Arrowman',
        weapon = 'Bow and Pointy Arrows',
        damage = 5,
        range = 20
    }
    self:reportPickup()
end

function Guy:reportPickup()
    print(self.name .. ' the ' .. self.prev .. ' has graduated to ' .. self.power['class'] .. '! He now carries a ' .. self.power['weapon'] .. ' with ' .. self.power['range'] .. ' range and ' .. self.power['damage'] .. ' damage.')
end
