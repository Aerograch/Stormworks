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

function Color(r, g, b)
    return {
        r = r,
        g = g,
        b = b
    }
end

function Target(distance, angle)
    return {
        distance = distance,
        angle = angle,
        time = 0,
        increment = function (me)
            me.time = me.time + 1
        end
    }
end

function setColorMy(color, opacity)
    opacity = opacity or 255
    screen.setColor(color.r, color.g, color.b, opacity)
end

drawParams = {
    radarLineX = 0,
    radarLineY = 0,
    radarMainShadowX = 0,
    radarMainShadowY = 0,
    radarSecondaryShadowX = 0,
    radarSecondaryShadowY = 0,
    targets = List({}),
    displayRange = 500,
    --displayMap = false,
    colors = {
        background = Color(5, 5, 5),
        text = Color(0, 255, 0),
        target = Color(255, 0, 0)
    }
}

radar = {
    rotation = 0,
    speed = 0,
    enabled = false,
    angle = 0,
    --gpsX = 0,
    --gpsY = 0
}

screenParams = {
    width = 0,
    height = 0,
    screenRadius = 0,
}

pi = math.pi

ticks = 0
function onTick()

    if screenParams.width == 0 then
        return
    end

    targetFound = input.getBool(1)
    distance = input.getNumber(1)

    drawParams.displayRange = input.getNumber(4)
    --drawParams.displayMap = input.getBool(3)

    radar.rotation = input.getNumber(2)%1
    radar.speed = (100 - input.getNumber(3)) * 6
    radar.enabled = input.getBool(2)
    radar.angle = radar.rotation*6.2832
    radar.gpsX = input.getNumber(5)
    radar.gpsY = input.getNumber(6)

    if radar.enabled then

        drawParams.radarLineX = screenParams.width/2 + screenParams.screenRadius * math.cos(radar.angle-1.5708)
		drawParams.radarLineY = screenParams.height/2 + screenParams.screenRadius * math.sin(radar.angle-1.5708)

		drawParams.radarMainShadowX = screenParams.width/2 + screenParams.screenRadius * math.cos(radar.angle-1.74533)
		drawParams.radarMainShadowY = screenParams.height/2 + screenParams.screenRadius * math.sin(radar.angle-1.74533)

		drawParams.radarSecondaryShadowX = screenParams.width/2 + screenParams.screenRadius * math.cos(radar.angle-1.91986)
		drawParams.radarSecondaryShadowY = screenParams.height/2 + screenParams.screenRadius * math.sin(radar.angle-1.91986)

        if targetFound then
            drawParams.targets.add(drawParams.targets, Target(distance, radar.angle))
        end
        removal = {}
        for i = 1, #drawParams.targets do
            drawParams.targets[i].increment(drawParams.targets[i])
            if drawParams.targets[i].time >= radar.speed then
                removal[#removal+1] = i
            end
        end
        for i = #removal, 1, -1 do
            drawParams.targets.remove(drawParams.targets, i)
        end
    end
end

function onDraw()

    screenParams.height = screen.getHeight()
    screenParams.width = screen.getWidth()
    screenParams.screenRadius = screen.getHeight()/2

    setColorMy(drawParams.colors.background)
    screen.drawClear()

    --if drawParams.displayMap then
    --    screen.drawMap(radar.gpsX, radar.gpsY, drawParams.displayRange/1000*2)
    --end


    setColorMy(drawParams.colors.text)
    screen.drawCircle(screenParams.width/2, screenParams.height/2, screenParams.screenRadius)
    setColorMy(drawParams.colors.text, 30)
    screen.drawCircle(screenParams.width/2, screenParams.height/2, screenParams.screenRadius/(5/1))
    screen.drawCircle(screenParams.width/2, screenParams.height/2, screenParams.screenRadius/(5/2))
    screen.drawCircle(screenParams.width/2, screenParams.height/2, screenParams.screenRadius/(5/3))
    screen.drawCircle(screenParams.width/2, screenParams.height/2, screenParams.screenRadius/(5/4))

    screen.drawLine(screenParams.width/2-screenParams.screenRadius, screenParams.height/2, screenParams.width/2+screenParams.screenRadius, screenParams.height/2)
    screen.drawLine(screenParams.width/2, screenParams.height/2-screenParams.screenRadius, screenParams.width/2, screenParams.height/2+screenParams.screenRadius)



    setColorMy(drawParams.colors.text)
    screen.drawTextBox(1, 1, 20, 8, string.format("%#0d", drawParams.displayRange), -1, -1)
    screen.drawLine(screenParams.width/2, screenParams.height/2, drawParams.radarLineX, drawParams.radarLineY)

    setColorMy(drawParams.colors.text, 150)
    screen.drawTriangleF(screenParams.width/2, screenParams.height/2, drawParams.radarMainShadowX, drawParams.radarMainShadowY, drawParams.radarLineX, drawParams.radarLineY)

    setColorMy(drawParams.colors.text, 100)
    screen.drawTriangleF(screenParams.width/2, screenParams.height/2, drawParams.radarMainShadowX, drawParams.radarMainShadowY, drawParams.radarSecondaryShadowX, drawParams.radarSecondaryShadowY)


    for i = 1, #drawParams.targets do
        target = drawParams.targets[i]
        x = screenParams.width/2 + (target.distance/drawParams.displayRange) * screenParams.screenRadius * math.cos(target.angle-1.5708)
        y = screenParams.height/2 + (target.distance/drawParams.displayRange) * screenParams.screenRadius * math.sin(target.angle-1.5708)

        setColorMy(drawParams.colors.target)
        screen.drawCircleF(x,y,1)
    end

end



