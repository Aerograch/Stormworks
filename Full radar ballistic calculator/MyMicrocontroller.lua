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
require("Types.List")


function Target()
    return {
        getGps = function (me)
            return me.positions.list[#me.positions.list][1]
        end,
        positions = List(),
        filter = ABVectorFilter(40),
        velocity = vector(),
        update = function (me, gps, counter)
            if #me.positions.list == 0 then
                me.positions:add({me.filter:step(gps, 1), counter})
            else
                me.positions:add({me.filter:step(gps, counter - me.positions.list[#me.positions.list]), counter})
            end
            if #me.positions.list > 10 then
                me.positions:remove(1)
            end

            lastPos = me.positions.list[1]
            thisPos = me.positions.list[#me.positions.list]
            me.velocity = thisPos[1]:subtract(lastPos[1]):dot((thisPos[2]-lastPos[2])/(60))
        end,
    }

end


function binarySearch(min, max, check, tgtDelta, tgtPoint)
    delta = 0
    iter = 50
    repeat
        mid = (max+min) / 2
        result = check(mid)
        delta = math.abs(result-tgtPoint)
        if result-tgtPoint < 0 then
            min = mid
        else
            max = mid
        end
        iter = iter - 1
        if iter == 0 then break end
    until delta < tgtDelta
    return mid
end

function CalculateHeight(a)
    y = 1/k*((tan(a)*k+(g/(v*cos(a))))*x + (g/k)*ln(1-x*(k/(v*cos(a)))))
    return y
end

function CalculateFlightTime(v0)
    t = (-1)*(1/k)*ln(1-(x*(k/v0)))
    return t
end


cos = math.cos
sin = math.sin
tan = math.tan
ln = math.log

resultAngle = 0
tgtX = 0
tgtY = 0

x = 0
k = 0
v = 0
g = 30

dist = 0
elevation = 0

calc = false

target = Target()



counter = 0
function onTick()
    counter = counter + 1
    pos = vector(input.getNumber(12), input.getNumber(13), input.getNumber(14))
    vehicleBasis = ijkb(input.getNumber(15), input.getNumber(16), input.getNumber(17))
    targetPos = vector(input.getNumber(3), input.getNumber(4), input.getNumber(5))
    temp = ijkb(targetPos[2]*pi*2, targetPos[3]*pi*2, 0, "aer")[3]
    localTarget = temp:dot(targetPos[1])
    globalTarget = localTarget:localToGlobal(vehicleBasis)
    targetGPS = globalTarget:add(pos)
    target:update(targetGPS, counter)

    k = input.getNumber(1)
    v = input.getNumber(2)

    t = 0
    shootingPoint = {}
    resultAngle = {}
    iter = 0

    repeat
        iter = iter + 1
        shootingPoint = target:getGps()
        shootingPoint = shootingPoint:add(target.velocity:dot(t))
        distance = len(shootingPoint[1], shootingPoint[2])
        x = distance
        altitude = shootingPoint[3]
        resultAngle = binarySearch(0, math.pi/4, CalculateHeight, 0.1, altitude) / (math.pi * 2)
        newT = CalculateFlightTime(cos(resultAngle*pi2)*v)
        dt = newT - t
        t = newT
        if iter == 50 then
            break
        end
    until dt < 0.1


    turretPos = vector(input.getNumber(6), input.getNumber(7), input.getNumber(8))
    turretBasis = ijkb(input.getNumber(9), input.getNumber(10), input.getNumber(11))

    targetCords = shootingPoint
    adjustedCords = turretPos:subtract(targetCords)
    localCords = adjustedCords:globalToLocal(turretBasis)
    targetingCords = localCords:normalize()
    if targetingCords[3] > 0 then
        targetingCords[1] = targetingCords[1] + 1*sgn(targetingCords[1])
    end

    output.setNumber(1, targetingCords[1])
    
    elevation = input.getNumber(18)

    output.setNumber(2, elevation - resultAngle)
    output.setNumber(3, dt)


end



