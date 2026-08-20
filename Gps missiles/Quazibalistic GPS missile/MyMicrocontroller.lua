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

control = {
    horizontal = PID(1, 0.01, 1, -1, 1, 1),
    vertical = PID(1, 0.01, 1, -1, 1, 1)
}

directGuidance = false

ticks = 0
function onTick() 
    launched = input.getBool(1)
    pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
    missileBasis = ijkb(input.getNumber(4), input.getNumber(5), input.getNumber(6))
    localMissileVelocity = vector(input.getNumber(7), input.getNumber(8), input.getNumber(9))
    globalMissileVelocity = localMissileVelocity:localToGlobal(missileBasis)
    targetCords = vector(input.getNumber(10), input.getNumber(11), input.getNumber(12))
    adjustedCords = targetCords:subtract(pos)

    directGuidance = vector(adjustedCords[1], 0, adjustedCords[3]):magnitude() < 100 or directGuidance and launched

    if not directGuidance then
        adjustedCords[2] = adjustedCords[2] + 5000
    end

    globalControl = adjustedCords:normalize():subtract(globalMissileVelocity:normalize())
    if not directGuidance then
        tgtHeightVector = vector(100, clamp(adjustedCords[2], -5000, 5000), 0):normalize()
        currentHeightVector = vector(100, globalMissileVelocity[2], 0):normalize()
        globalControl = vector(globalControl[1], tgtHeightVector:subtract(currentHeightVector)[2], globalControl[3])
    end
 
    localCords = globalControl:globalToLocal(missileBasis)
    localCords = vector(-localCords[1], localCords[2], -localCords[3])
    localControl = localCords:cartesianToPolar()

    control.horizontal:update(0, -localControl[1]*clamp(localCords:magnitude()*10, 0, 1), launched)
    control.vertical:update(0, localControl[2]*clamp(localCords:magnitude()*10, 0, 1), launched)

    output.setNumber(1, control.horizontal.control)
    output.setNumber(2, control.vertical.control)
    output.setNumber(3, globalMissileVelocity[1]) 
    output.setNumber(4, globalMissileVelocity[2])
    output.setNumber(5, globalMissileVelocity[3])
    output.setNumber(6, globalControl[1])
    output.setNumber(7, globalControl[2])
    output.setNumber(8, globalControl[3])
    output.setNumber(9, localCords[1])
    output.setNumber(10, localCords[2])
    output.setNumber(11, localCords[3])
end





