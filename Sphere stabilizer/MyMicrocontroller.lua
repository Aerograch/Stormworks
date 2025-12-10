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
require("Math.PIDs")

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
--- 10 - desirableAzimuthDeviation
--- 11 - desirableElevationDeviation
--- 
--- bools
--- 1 - outerTargetMode

target = vector()
init = {true, 1}
ticks = 0 
PIDAzimuth = {}
PIDElevation = {}
function onTick()
    euler = vector(input.getNumber(4), input.getNumber(5), input.getNumber(6))
    turretBasis = ijkb(euler[1], euler[2], euler[3])
    if init[1] then
        init[2] = init[2] - 1
        if init[2] <= 0 then
            init[1] = false
        end
        target = vector(0, 0, 1)---:localToGlobal(turretBasis) --- set target on init phase directly front
        
        ---PIDAzimuth = IntegralBoundPID(
        ---    property.getNumber("Azimuth P"),
        ---    property.getNumber("Azimuth I"),
        ---    property.getNumber("Azimuth D"),
        ---    0.5
        ---)

        ---PIDElevation = IntegralBoundPID(
        ---    property.getNumber("Elevation P"),
        ---    property.getNumber("Elevation I"),
        ---    property.getNumber("Elevation D"),
        ---    0.5
        ---)
        
        return
    end

    pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
    outerTargetMode = input.getBool(1)

    if outerTargetMode then
       target = vector(input.getNumber(7), input.getNumber(8), input.getNumber(9)):subtract(pos)
       target = vector(-target[1], target[2], -target[3])
    else
        target = target:globalToLocal(turretBasis)
        local targetAsPolar = target:cartesianToPolar()
        deltaAzimuth = input.getNumber(10)
        deltaElevation = input.getNumber(11)
        targetAsPolar = vector(
            targetAsPolar[1] + deltaAzimuth/100,
            targetAsPolar[2] + deltaElevation/100,
            targetAsPolar[3]
        )
        target = targetAsPolar:polarToCartesian():localToGlobal(turretBasis)
    end

    local targetAsPolar = target:globalToLocal(turretBasis):cartesianToPolar()

    azimuth = targetAsPolar[1]
    elevation = targetAsPolar[2]

    ---azimuthTarget = targetAsPolar[1]
    ---elevationTarget = targetAsPolar[2]

    ---azimuth = PIDAzimuth:step(0, azimuthTarget)
    ---elevation = PIDElevation:step(0, elevationTarget)

    output.setNumber(1, azimuth ~= azimuth and 0 or azimuth)
    output.setNumber(2, elevation ~= elevation and 0 or elevation)
    output.setNumber(3, target:globalToLocal(turretBasis)[1])
    output.setNumber(4, target:globalToLocal(turretBasis)[2])
    output.setNumber(5, target:globalToLocal(turretBasis)[3])
    

end

function onDraw()
    
end



