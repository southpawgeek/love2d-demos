function love.load()
    mousefocus = "mousefocus - n/a"
    mousemoved = "mousemoved - n/a"
    mousemovedd = "mousemoved - n/a"
    mousepressed = "mousepressed - n/a"
    mousereleased = "mousereleased - n/a"
    isgrabbed = "grabbed - n/a"
    grabbed = false
    focused = false
end

function love.update(dt)
     grabbed = love.mouse.isGrabbed()
    if grabbed then
        isgrabbed = "grabbed - true"
    else
        isgrabbed = "grabbed - false"
    end
end

function love.draw()
    love.graphics.print(mousefocus, 10, 10)
    love.graphics.print(mousemoved, 10, 25)
    love.graphics.print(mousemovedd, 10, 40)
    love.graphics.print(mousepressed, 10, 55)
    love.graphics.print(mousereleased, 10, 70)
    love.graphics.print(isgrabbed, 10, 85)
end

function love.mousemoved(x, y, dx, dy, istouch)
    mousemoved = "mousemoved - x: " .. x .. " y: " .. y
    mousemovedd = "mousemoved - dx: " .. dx .. " dy: " .. dy
end

function love.mousepressed(x, y, button, istouch, presses)
    mousepressed = "mousepressed - x: " .. x .. " y: " .. y .. " button: " .. button .. " presses: " .. presses

    -- if you click mouse1, the window will grab the cursor
    if focus and button == 1 then
        grabbed = true
    else
        grabbed = false
    end

    -- right click to release the cursor
    if button == 2 then
        grabbed = false
    end

    -- grab is only set on mouse clicks
    love.mouse.setGrabbed(grabbed)
end

function love.mousereleased(x, y, button, istouch, presses)
    mousereleased = "mousereleased - x: " .. x .. " y: " .. y .. " button: " .. button .. " presses: " .. presses
end

function love.mousefocus(f)
    if f then
        focus = true
        mousefocus = "mousefocus - hoem"
    else
        focus = false
        mousefocus = "mousefocus - not hoem"
    end
end
