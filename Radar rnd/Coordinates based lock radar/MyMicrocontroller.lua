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
require("Math.Filters")
require("LifeBoatAPI")

--- channels:
--- numbers
--- 1 - gpsX
--- 2 - gpsY
--- 3 - gpsZ
--- 4 - eulerX
--- 5 - eulerY
--- 6 - eulerZ
--- 7 - targetX (in world coordinates)
--- 8 - targetY (in world coordinates)
--- 9 - targetZ (in world coordinates)
--- 10 - radar target distance
--- 11 - radar target azimuth
--- 12 - radar target elevation
--- 
--- bools
--- 1 - lock target
--- 2 - radar found target

posBuffer = {}
secondAgoTargetPos = vector()
aligned = false
velocity = vector()

radarDataAvg = RollingVectorAverage(60)
velocityDataAvg = RollingVectorAverage(15)

target = vector()
function onTick()
    lockTarget = input.getBool(1)
    foundRadarTarget = input.getBool(2)
    aligned = lockTarget and aligned or false
    azimuth = 0;
    elevation = 0;

    if lockTarget then
        euler = vector(input.getNumber(4), input.getNumber(5), input.getNumber(6))
        turretBasis = ijkb(euler[1], euler[2], euler[3])
        pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
        if aligned and foundRadarTarget then
            
            radarData = radarDataAvg:addValue(
                vector(input.getNumber(10), input.getNumber(11), input.getNumber(12))
            )
            basisData = ijkb(radarData[2]*pi2, radarData[3]*pi2, 0, "aer")[3]
            localTarget = basisData:dot(radarData[1])
            globalTarget = localTarget:localToGlobal(turretBasis)
            target = globalTarget:add(pos)
            if #posBuffer == 0 then
                posBuffer[1] = target
            else
                for i = #posBuffer < 60 and #posBuffer + 1 or #posBuffer, 2, -1 do
                    posBuffer[i] = posBuffer[i-1]
                end
                posBuffer[1] = target
            end

            if #posBuffer == 60 then
                velocity = velocityDataAvg:addValue(
                    posBuffer[1]:subtract(posBuffer[#posBuffer]):dot(1/#posBuffer):dot(60)
                )
            end

            target = target:add(velocity:dot(0.5))
            output.setNumber(32, #posBuffer)
        else
            target = vector(input.getNumber(7), input.getNumber(8), input.getNumber(9))
            velocity = vector()
        end
        localTarget = target:subtract(pos)
        localTarget = vector(-localTarget[1], localTarget[2], -localTarget[3])
        targetAsPolar = localTarget:globalToLocal(turretBasis):cartesianToPolar()
        azimuth = -targetAsPolar[1] / pi2
        elevation = targetAsPolar[2] / pi2
        aligned = true
    else
        posBuffer = {}
        aligned = false
        radarDataAvg = RollingVectorAverage(60)
    end

    output.setNumber(1, azimuth ~= azimuth and 0 or azimuth)
    output.setNumber(2, elevation ~= elevation and 0 or elevation)

    output.setNumber(3, target[1])
    output.setNumber(4, target[2])
    output.setNumber(5, target[3])

    output.setNumber(6, velocity[1])
    output.setNumber(7, velocity[2])
    output.setNumber(8, velocity[3])
end

function onDraw()
    
end



