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

--- channels:
--- numbers
--- input
--- 1 - gpsX
--- 2 - gpsY
--- 3 - gpsZ    
--- 4 - eulerX
--- 5 - eulerY
--- 6 - eulerZ
--- 7 - horizontalControl
--- 8 - verticalControl
--- 9 - distance
--- output
--- 1 - pointerX
--- 2 - pointerY
--- 3 - targetX
--- 4 - targetY
--- 5 - targetZ
--- bool
--- input
--- 1 - lock

tagpsTargetrget = vector()
pointerPosition = {0, 0}

function onTick()
    pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
    turretBasis = ijkb(input.getNumber(4), input.getNumber(5), input.getNumber(6))
    lock = input.getBool(1)

    
    if not lock then
        --gpsTarget = vector(-pointerPosition[1] * pi2 / 8, pointerPosition[2] * pi2 / 8, input.getNumber(9))
        --gpsTarget = gpsTarget:polarToCartesian()
        gpsTarget = ijkb(pointerPosition[1] * pi2 / 8, pointerPosition[2] * pi2 / 8, 0, "aer")[3]:dot(input.getNumber(9)):localToGlobal(turretBasis)
        gpsTarget = vector(gpsTarget[1], gpsTarget[2], gpsTarget[3]):add(pos)
        pointerPosition = {pointerPosition[1] + input.getNumber(7)*0.001, pointerPosition[2] + input.getNumber(8)*0.001}
    else
        target = gpsTarget:subtract(pos)
        targetAsPolar = vector(-target[1], target[2], -target[3]):globalToLocal(turretBasis):cartesianToPolar()
        pointerPosition = {-targetAsPolar[1] / pi2 * 8, targetAsPolar[2] / pi2 * 8}
    end

    output.setNumber(1, pointerPosition[1] ~= pointerPosition[1] and 0 or pointerPosition[1])
    output.setNumber(2, pointerPosition[2] ~= pointerPosition[2] and 0 or pointerPosition[2])
    output.setNumber(3, gpsTarget[1])
    output.setNumber(4, gpsTarget[2])
    output.setNumber(5, gpsTarget[3])

end


