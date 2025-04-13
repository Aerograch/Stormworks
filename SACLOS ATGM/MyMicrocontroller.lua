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

function nanCheck(a)
    if a ~= a then
        return 0
    end
    return a
end

function calculateAngularDeviation(pos, line)
    deviation = {
        tilt = 0,
        compass = 0
    }
    
    deviation.tilt = nanCheck(pos.tilt - line.tilt)

    if math.abs(pos.compass) > 0.25 then
		pos.compass = (pos.compass + 1) % 1 - 0.5
		line.compass = (line.compass + 1) % 1 - 0.5
    end

    deviation.compass = nanCheck(pos.compass - line.compass)
    return deviation
end

function calculateDeviation(pos, line)
    linePoint = {
        x = 0,
        y = 0,
        z = 0
    }
    linePoint.y = (((line.a)^2*line.y0)/line.b - (line.x0-pos.x)*line.a + line.b*pos.y + (line.c^2*line.y0)/line.b - (line.z0-pos.z)*line.c)*(line.b/(line.a^2+line.b^2+line.c^2))

    linePoint.x = (line.a/line.b)*(linePoint.y-line.y0) + line.x0

    linePoint.z = (line.c/line.b)*(linePoint.y-line.y0) + line.z0

    deviationAbsolute = {
        x = linePoint.x-pos.x,
        y = linePoint.y-pos.y,
        z = linePoint.z-pos.z
    }

    -- Get angles.
    x = pos.eulerX
    y = pos.eulerY
    z = pos.eulerZ

    -- sin, 'cos I like it.
    cx, sx = math.cos(x), math.sin(x)
    cy, sy = math.cos(y), math.sin(y)
    cz, sz = math.cos(z), math.sin(z)

    -- Build matrix.
    m00 = cy*cz
    m01 = -cx*sz + sx*sy*cz
    m02 = sx*sz + cx*sy*cz
    m10 = cy*sz
    m11 = cx*cz + sx*sy*sz
    m12 = -sx*cz + cx*sy*sz
    m20 = -sy
    m21 = sx*cy
    m22 = cx*cy

    deviationRelative = {
        x = nanCheck(m00*deviationAbsolute.x + m10*deviationAbsolute.y + m20*deviationAbsolute.z),
        y = nanCheck(m01*deviationAbsolute.x + m11*deviationAbsolute.y + m21*deviationAbsolute.z)
    }

    return deviationRelative
end

myPos = {
    x = 0,
    y = 0,
    z = 0,
    tilt = 0,
    compass = 0,
    eulerX = 0,
    eulerY = 0,
    eulerZ = 0,
}

tgtLine = {
    x0 = 0,
    y0 = 0,
    z0 = 0,
    a = 0,
    b = 0,
    c = 0,
    tilt = 0,
    compass = 0
}

function onTick()
    enable = input.getBool(1)

    myPos.x = input.getNumber(1)
    myPos.y = input.getNumber(2)
    myPos.z = input.getNumber(3)
    myPos.tilt = input.getNumber(4)
    myPos.compass = input.getNumber(5)
    myPos.eulerX = input.getNumber(14)
    myPos.eulerY = input.getNumber(15)
    myPos.eulerZ = input.getNumber(16)

    tgtLine.x0 = input.getNumber(6)
    tgtLine.y0 = input.getNumber(7)
    tgtLine.z0 = input.getNumber(8)
    tgtLine.a = input.getNumber(9)
    tgtLine.b = input.getNumber(10)
    tgtLine.c = input.getNumber(11)
    tgtLine.tilt = input.getNumber(12)
    tgtLine.compass = input.getNumber(13)

    if enable then
        linearDeviation = calculateDeviation(myPos, tgtLine)
        angularDeviation = calculateAngularDeviation(myPos, tgtLine)
    else
        linearDeviation = {
            x = 0,
            y = 0
        }
        angularDeviation = {
            tilt = 0,
            compass = 0
        }
    end

    output.setNumber(1, linearDeviation.x)
    output.setNumber(2, linearDeviation.y)
    output.setNumber(3, angularDeviation.tilt)
    output.setNumber(4, angularDeviation.compass)
end





