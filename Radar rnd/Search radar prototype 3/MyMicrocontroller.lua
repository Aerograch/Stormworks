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

require("Math.Vectors")
require("Math.Basics")

function target()
    
end

targetGPS = vector(0,0,0)
pos = vector(0,0,0)
zoom = 0.1
target = vector(0,0,0)

function onTick()
    pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
    vehicleBasis = ijkb(input.getNumber(4), input.getNumber(5), input.getNumber(6))
    target = vector(input.getNumber(7), input.getNumber(8), input.getNumber(9))
    zoom = input.getNumber(10)
    temp = ijkb(target[2]*pi*2, target[3]*pi*2, 0, "aer")[3]
    localTarget = temp:dot(target[1])
    globalTarget = localTarget:localToGlobal(vehicleBasis)
    targetGPS = globalTarget:add(pos)
end

function onDraw()
    screen.drawMap(pos[1], pos[3], zoom)
    mapX, mapY = map.mapToScreen(pos[1], pos[3], zoom, screen.getWidth(), screen.getHeight(), targetGPS[1], targetGPS[3])
    screen.setColor(255, 0, 0)
    screen.drawCircleF(mapX, mapY, 1)
    screen.drawText(0,0, tostring(target[1]) .. " " .. tostring(target[2]) .. " " .. tostring(target[3]))
end



