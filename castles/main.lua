Class = require 'class'
require 'NamePool'
require 'Guy'
require 'Tserial'

function love.load()
    math.randomseed(os.time())
    NamePool = NamePool()
    Guys = {
        Guy(), Guy(), Guy(), Guy()
    }

    Guys[1]:pickupMagic()
    Guys[3]:pickupArrows()
end
