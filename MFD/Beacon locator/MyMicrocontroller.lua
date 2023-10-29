--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!
function Button(cords, type, hitboxCords, label, state, statefunc, color, draw, touchfunc, heldfunc)
    function generateHitbox()
        if type == 1 then --rect matching visual
            return cords
        end
        if type == 2 then --circle
            return 
            {
                x = cords.x - cords.rim,
                y = cords.y - cords.rim,
                w = cords.rim * 2-1,
                h = cords.rim * 2-1
            }
        end
    end
    return
    {
        cords = cords,
        type = type or 1,
        hitboxCords = hitboxCords or generateHitbox(),
        label = label or '',
        state = state or false,
        statefunc = statefunc or function(me)
            me.state = not me.state
        end,
        color = color or {255, 255, 255},
        draw = draw or drawButton,
        touchfunc = touchfunc or null,
        heldfunc = heldfunc or null
    }
end

function ping(x, y, time)
    return 
    {
        x = x,
        y = y,
        dist = time * 50 - 150
    }
end

function drawTextOnlyButton(btn)
    if btn.state then
        screen.setColor(unpackColor(btn.color))
        screen.drawText(btn.cords.x, btn.cords.y, btn.label)
    end
    
end

function drawButton(btn)
    if btn.state then
        screen.setColor(unpackColor(btn.color))
        screen.drawRectF(btn.cords.x, btn.cords.y, btn.cords.w, btn.cords.h)
    end
end

function drawCircleButton(btn)
    if btn.state then
        screen.setColor(unpackColor(btn.color))
        screen.drawCircleF(btn.cords.x, btn.cords.y, btn.cords.rim)
    end
end

function drawCircleButtonWithFill(btn)
    screen.setColor(unpackColor(btn.color.rim))
    screen.drawCircleF(btn.cords.x, btn.cords.y, btn.cords.rim)
    if btn.state then
        screen.setColor(unpackColor(btn.color.on))
        screen.drawCircleF(btn.cords.x, btn.cords.y, btn.cords.body)
    else
        screen.setColor(unpackColor(btn.color.off))
        screen.drawCircleF(btn.cords.x, btn.cords.y, btn.cords.body)
    end
end

function unpackColor(c)
    return c[1], c[2], c[3]
end

function isInbound(btn, x, y)
    if x >= btn.hitboxCords.x and x <= btn.hitboxCords.x + btn.hitboxCords.w and y >= btn.hitboxCords.y and y <= btn.hitboxCords.y + btn.hitboxCords.h then
        return true
    end
    return false
end

function addPing()
    transponderPings[#transponderPings + 1] = ping(pos.x, pos.y, btt)
end

function drawPing(ping)
    x, y = map.mapToScreen(pos.x, pos.y, scale, 96, 96, ping.x, ping.y)
    radius = ping.dist/(1000*scale)*96
    screen.setColor(255, 255, 0)
    screen.drawCircle(x, y, radius)
end

function clearPings()
    transponderPings = {}
end

function null()

end

buttons =
{
    Button(
        {
            x = 88,
            y = 48,
            rim = 5,
            body = 4
        },
        2,
        nil,
        nil,
        false,
        nil,
        {
            rim = {255, 255, 255},
            on = {0, 255, 0},
            off = {255, 0, 0}
        },
        drawCircleButtonWithFill,
        function (me)
            fetchScaleFromKeyboard = not me.state
        end
    ),

    Button(
        {
            x = 88,
            y = 36,
            rim = 5
        },
        2,
        nil,
        nil,
        true,
        null,
        {255, 255, 255},
        drawCircleButton,
        addPing
    ),

    Button(
        {
            x = 88,
            y = 60,
            rim = 5
        },
        2,
        nil,
        nil,
        true,
        null,
        {255, 255, 255},
        drawCircleButton,
        clearPings
    )
}

transponderPings = {}

btt = 0
ticks = 0

fetchScaleFromKeyboard = true
scale = 1
pos =
{
    x = 0,
    y = 0
}

touch1 = {
    touched = false,
    held = false,
    x = 0,
    y = 0
}

mode = 0
function onTick()
    mode = input.getNumber(32)
    if mode ~= 0 then
        return
    end
    --btt
    if input.getBool(3) then
        btt = ticks
        ticks = 0
    else
        ticks = ticks + 1
    end

    --inputs
    pos.x = input.getNumber(15)
    pos.y = input.getNumber(16)

    touch1.touched = input.getBool(1) and not touch1.held
    touch1.held = input.getBool(1)
    touch1.x = input.getNumber(3)
    touch1.y = input.getNumber(4)

    if fetchScaleFromKeyboard == true then
        scale = input.getNumber(17)
    end
end


function onDraw()
    if mode ~= 0 then
        return
    end
    screen.drawMap(pos.x, pos.y, scale)

    for i = 1, #buttons do
        buttons[i].draw(buttons[i])
    end

    if touch1.touched then
        for i = 1, #buttons do
            if isInbound(buttons[i], touch1.x, touch1.y) then
                buttons[i].touchfunc(buttons[i])
                buttons[i].statefunc(buttons[i])
            end
        end
    end

    for i = 1, #transponderPings do
        drawPing(transponderPings[i])
    end
end



