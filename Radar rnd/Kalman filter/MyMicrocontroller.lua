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

---Creates A-B Kalman filter instance
---@param k_max number
---@return table
function ABFilter(k_max)
    return {
        k_max=k_max,
        k=0,
        zFiltered = 0,
        speedFiltered = 0,
        zPredicted = 0,
        speedPredicted = 0,
        ---Steps A-B filter and returns result
        ---@param a table
        ---@param z number
        ---@param dt any
        ---@return number
        step=function (a, z, dt)
            dt = dt or 16.6
            if k == 0 then
                a.zFiltered = z
                a.k = a.k + 1
            elseif k == 1 then
                a.speedFiltered = (z-a.zFiltered)/dt
                a.zFiltered = z
                a.zPredicted = a.zFiltered + dt*a.speedFiltered
                a.speedPredicted = a.speedFiltered
                a.k = a.k + 1
            else
                alpha = (2*(2*a.k - 1))/(a.k*(a.k+1))
                beta = 6/(a.k*(a.k+1))
                a.zFiltered = a.zPredicted + alpha*(z - a.zPredicted)
                a.speedFiltered = a.speedPredicted + (beta/dt)*(z - a.zPredicted)
                a.zPredicted = a.zFiltered + a.speedFiltered*dt
                a.k = a.k < k_max and a.k + 1 or k_max
            end
            return a.zFiltered
        end
    }
end


function onTick()
    ticks = ticks + 1
end

function onDraw()
    screen.drawCircle(16,16,5)
end



