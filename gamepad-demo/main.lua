function love.load()
    lastbutton="none"
end

function love.gamepadpressed(joystick, button)
    lastbutton=button

end

function love.draw()
     local joysticks = love.joystick.getJoysticks()

    for i, joystick in ipairs(joysticks) do
        if joystick:isConnected() then
            local name = joystick:getName()
            local axes = joystick:getAxisCount()
            local hat = joystick:getHat(1)

            local lx, ly, rx, ry, lt, rt = joystick:getAxes()
            lx = string.format("%.2f", lx)
            ly = string.format("%.2f", ly)
            rx = string.format("%.2f", rx)
            ry = string.format("%.2f", ry)
            lt = string.format("%.2f", lt)
            rt = string.format("%.2f", rt)
            love.graphics.print(name .. ", " .. axes .. " axes found. LX:" .. lx .. " LY:" .. ly .. " :: RX:" .. rx .. " RY:" .. ry .. " :: LT:" .. lt .. " RT:".. rt .. " HAT:" .. hat .. " LAST:" .. lastbutton, 10, i * 20)
        end
    end
end