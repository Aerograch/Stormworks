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
--require("ScreenLib.Button")

function Button(cords, label, state, statefunc, color, draw, func)
    return 
    {
        x = cords[1],
        y = cords[2],
        w = cords[3],
        h = cords[4],
        label = label,
        state = state,
        statefunc = statefunc or function(me)
            me.state = not me.state
        end,
        color = color or {255, 255, 255},
        draw = draw,
        func = func
    }
end

function drawTextOnlyButton(btn)
    if btn.state then
        screen.drawText(btn.x, btn.y, btn.label)
    end
    
end

function drawButton(btn)
    if btn.state then
        screen.setColor(btn.color)
        screen.drawRectF(btn.x, btn.y, btn.w, btn.h)
    end
end

function isInbound(btn, x, y)
    if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
        return true
    end
    return false
end

function clearStates()
    states =
    {
        nav = false,
        eng = false,
        fuel = false,
        hor = false,
        cnt = false,
        wpn = false
    }
end

buttons = 
{
    --navigation
    Button(
        {0, 3, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[2].state = not buttons[2].state end
    ),
    Button(
        {4, 5, 15, 7},
        'nav',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.nav = true
            end
        end
    ),

    --engines
    Button(
        {0, 19, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[4].state = not buttons[4].state end
    ),
    Button(
        {4, 21, 15, 7},
        'eng',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.eng = true
            end
        end
    ),

    --fuel
    Button(
        {0, 35, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[6].state = not buttons[6].state end
    ),
    Button(
        {4, 37, 20, 7},
        'fuel',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.fuel = true
            end
        end
    ),

    --horizon
    Button(
        {0, 51, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[8].state = not buttons[8].state end
    ),
    Button(
        {4, 53, 15, 7},
        'hor',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.hor = true
            end
        end
    ),

    --Weapon count
    Button(
        {0, 67, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[10].state = not buttons[10].state end
    ),
    Button(
        {4, 69, 15, 7},
        'cnt',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.cnt = true
            end
        end
    ),

    --weapon use
    Button(
        {0, 83, 2, 9},
        '',
        true,
        function() end,
        nil,
        drawButton,
        function () buttons[12].state = not buttons[12].state end
    ),
    Button(
        {4, 85, 15, 7},
        'wpn',
        false,
        function (me)
            me.state = false
        end,
        nil,
        drawTextOnlyButton,
        function (me)
            if me.state then
                clearStates()
                states.wpn = true
            end
        end
    )
}

states =
{
    nav = false,
    eng = false,
    fuel = false,
    hor = false,
    cnt = false,
    wpn = false
}

touch1 = {
    touched = false,
    held = false,
    x = 0,
    y = 0
}
touch2 = false

mode = 0
function onTick()
    touch1.touched = input.getBool(1) and not touch1.held
    touch1.held = input.getBool(1)
    touch1.x = input.getNumber(3)
    touch1.y = input.getNumber(4)

    if states.nav then
        mode = 0
    end
    if states.eng then
        mode = 1
    end
    if states.fuel then
        mode = 2
    end
    if states.hor then
        mode = 3
    end
    if states.cnt then
        mode = 4
    end
    if states.wpn then
        mode = 5
    end

    output.setNumber(32, mode)
end

function onDraw()
    for i = 1, #buttons do
        buttons[i].draw(buttons[i])
    end

    if touch1.touched then
        for i = 1, #buttons do
            if isInbound(buttons[i], touch1.x, touch1.y) then
                buttons[i].func(buttons[i])
                buttons[i].statefunc(buttons[i])
            end
        end
    end

end

function switchNav()

end



