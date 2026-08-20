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

---inputs
---number
---1 - Assigned ID
---bool
---1 - Assume ID
---2 - Assume Master and start initialization
---3 - Previously inverted
---4 - Currently inverted
---output
---number
---1 - ID for Assignment
---bool
---1 - Assume ID
---2 - Am master
---3 - Inverted thrust

id = 0
master = false
initialized = false
function onTick()
    output.setBool(1, false)
    output.setNumber(1, 0)
    if input.getBool(2) and not master then
        master = true
        initialized = false
        id = 1
        output.setBool(1, true)
        output.setNumber(1, id + 1)
    end
    if input.getBool(1) then
        if master and not initialized then
            initialized = true
        else if master and initialized then
            master = false
            initialized = true
            id = input.getNumber(1)
            output.setBool(1, true)
            output.setNumber(1, id + 1)
        else if not master then
            initialized = true
            id = input.getNumber(1)
            output.setBool(1, true)
            output.setNumber(1, id + 1)
        end end end
    end
    inverted = input.getBool(4) and not master
    output.setBool(3, inverted)
    output.setBool(2, master)
    output.setNumber(32, id)
end

function onDraw()
    screen.drawCircle(16,16,5)
end



