NamePool = Class{}

function NamePool:init()
    --print('init NamePool')
    self.pool = {'Guy', 'Buddy', 'Pal', 'Chief', 'Friend', 'Bro', 'Dude', 'Man', 'Champ'}
end

function NamePool:get()
    name = self.pool[ math.random(#self.pool) ]
    --print('NamePool:get ' .. name)
    return name
end