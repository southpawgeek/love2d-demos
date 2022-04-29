DT = 0
X = 0
SINE = {}

function love.update(dt)
    DT = DT + dt
end

function love.draw()
    love.graphics.setColor(1,1,0,1)
    love.graphics.circle('fill', 400, 225, 200)

    for i=0, 7 do
        local y = 275 + i * 20

        love.graphics.setColor(0,0,0,1)
        love.graphics.setLineWidth(i^2 + 1)
        love.graphics.line(0, y, 800, y)
    end

    for i=0, 8 do
        local y2 = 346 + i * 50
        love.graphics.setLineWidth(2)
        love.graphics.setColor(0,0,1,1)
        love.graphics.line(0,y2, 800, y2)

        love.graphics.line(i*100, 346, i*150, 600)
    end

    local diff = math.cos(DT) * 100 + 300

    -- love.graphics.setColor(1,0,1,1)
    -- table.insert(SINE, {X, diff})
    -- for coord in pairs(SINE) do
    --     love.graphics.points(coord[1], coord[2])
    -- end
    -- love.graphics.points(table.unpack(SINE))

    -- X=X+1
    -- if X > 800 then
    --     X = 0
    -- end
end