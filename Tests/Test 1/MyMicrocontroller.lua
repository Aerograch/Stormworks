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

ticks = 0
field = 8
r = 30
size = 96
left = 0
up = 0
ud = 0

function drawSemiCircleF(x, y, r, k, h, f, c)
    -- x, y, r задают окружность
    -- k, h задают прямую 
    -- f = {-1, 1} задаёт, какую чатсь окружности брать. 1 - верхнюю, -1 - нижнюю
    -- При k > 1000 -1 - левая, 1 - правая
    -- c - цвет. g - ground, s - sky
    -- 204 102 0
    -- 0 255 255
    if c == 's' then
        screen.setColor(0, 255, 255)
    else
        screen.setColor(204, 102, 0)
    end
    for i = x - r, x + r, 1 do
        for j = y - r, y + r, 1 do
            if (((i - x) ^ 2 + (j - y) ^ 2) <= r^2) and ((f * (j + k*(i - x) - y + h)) < 0) then
                screen.drawCircle(i, j, 1)
            end
        end
    end
end

function sgn(x)
    if x > 0 then 
        return 1
    else 
        return -1
    end
end

function onTick()
    ticks = ticks + 1
    left = -input.getNumber(12)
    up = -input.getNumber(13)
    ud = input.getNumber(14)
end

function onDraw()
    screen.setColor(255, 255, 255)
    screen.drawCircleF(size/2, field+r, r)

    drawSemiCircleF(size/2, field+r, r, math.tan(2*math.pi*left), up*4*r/math.cos(2*math.pi*left)*sgn(ud), sgn(ud), 's')
    drawSemiCircleF(size/2, field+r, r, math.tan(2*math.pi*left), up*4*r/math.cos(2*math.pi*left)*sgn(ud), -sgn(ud), 'g')

    screen.setColor(0, 0, 0)
    screen.drawRectF(0, 8, 28, 60)
    screen.drawRectF(68, 8, 28, 60)
    screen.drawLine(size/2, 38, size/2 + 1, 38 + 1)


end



