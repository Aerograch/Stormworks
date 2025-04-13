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
        simulator:setInputNumber(1, 1)
        simulator:setInputNumber(2, 1)
        simulator:setInputNumber(21, 0)
        simulator:setInputNumber(22, 0)
        simulator:setInputNumber(23, 0)

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
function List(values)
    values = values or {}
    values.remove = function (me, index)
        length = #me
        for i = index, length do
            me[i] = me[i+1]
        end
        me[length] = nil
    end
    values.add = function (me, item, index)
        if index then
            length = #me
            for i = length, index, -1 do
                me[i+1] = me[i]
            end
            me[index] = item
        else
            me[#me+1] = item
        end
    end
    return values
end

function drawPointer(x,y,s,r,a) -- position x,y, size, direction, angle/width of the arrow (optional)
    a = (a or 30)*math.pi/360
    x1 = x
    y1 = y
    x = x+s/2*math.sin(r)
    y = y-s/2*math.cos(r)
    screen.setColor(255, 255, 255, 255)
    screen.drawTriangleF(x,y, x-s*math.sin(r+a), y+s*math.cos(r+a), x-s*math.sin(r-a), y+s*math.cos(r-a))
    screen.setColor(0, 255, 0, 255)
    screen.drawLine(x, y, x1, y1)
end

buoysCords = {}
mainShip = {
    x = 0,
    y = 0,
    heading = 0
}

pairShip = {
    x = 0,
    y = 0,
    heading = 0
}

function onTick()
    buoysCords = List()
    for i = 1, 10 do
        if input.getNumber(i*2-1) == 0 then
            break
        end
        buoysCords.add(buoysCords, {x = input.getNumber(i*2-1), y = input.getNumber(i*2)})
    end

    mainShip.x = input.getNumber(21)
    mainShip.y = input.getNumber(22)
    mainShip.heading = input.getNumber(23)

    pairShip.x = input.getNumber(24)
    pairShip.y = input.getNumber(25)
    pairShip.heading = input.getNumber(26)
end


function onDraw()
    zoom = 1
    width = screen.getWidth()
    height = screen.getHeight()

    screen.drawMap(mainShip.x, mainShip.y, zoom)

    if #buoysCords>0 then

        screen.setColor(255, 165, 0)
        x2, y2 = map.mapToScreen(mainShip.x, mainShip.y, zoom, width, height, buoysCords[1].x, buoysCords[1].y)
        screen.drawLine(width/2, height/2, x2, y2)
        for i = 2, #buoysCords do
            x, y = map.mapToScreen(mainShip.x, mainShip.y, zoom, width, height, buoysCords[i].x, buoysCords[i].y)
            x1, y1 = map.mapToScreen(mainShip.x, mainShip.y, zoom, width, height, buoysCords[i-1].x, buoysCords[i-1].y)
            screen.drawLine(x, y, x1, y1)
        end

        screen.setColor(255, 0, 0)
        for i = 1, #buoysCords do
            x, y = map.mapToScreen(mainShip.x, mainShip.y, zoom, width, height, buoysCords[i].x, buoysCords[i].y)
            screen.drawCircleF(x, y, 2)
        end
    end
    screen.setColor(255, 255, 255)

    drawPointer(width/2, height/2, 7, mainShip.heading, 60)
end



