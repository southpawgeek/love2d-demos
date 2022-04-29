--[[
Any live cell with fewer than two live neighbours dies, as if by underpopulation.
Any live cell with two or three live neighbours lives on to the next generation.
Any live cell with more than three live neighbours dies, as if by overpopulation.
Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
These rules, which compare the behavior of the automaton to real life, can be condensed into the following:

Any live cell with two or three live neighbours survives.
Any dead cell with three live neighbours becomes a live cell.
All other live cells die in the next generation. Similarly, all other dead cells stay dead.
]]


sx, sy = 0, 0

lines = {}

function love.mousepressed(x, y, button)
    sx = x
    sy = y
end

function love.mousereleased(x, y)
    line = {x1=sx, y1=sy, x2=x, y2=y}
    table.insert(lines, line)
end

function love.mousemoved(x, y, dx, dy)
    line={x1=x, y1=y, x2=dx, y2=dy}
end

function love.draw()
    for i=1, #lines do
        love.graphics.line(lines[i].x1, lines[i].y1, lines[i].x2, lines[i].y2)
    end
end


function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end