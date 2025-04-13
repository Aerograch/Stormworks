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

vAxis = 0
hAxisSetpoint = 0
hAxisVariable = 0
sens = 0.01
isInverted = false
function onTick()
	-- sens setting up
	sens = input.getNumber(1)

	-- vAxis setting up
	vAxisInput = input.getNumber(2)
	if mode then
		vAxis = vAxisInput
	else
		if vAxisInput > 0.05 then
			vAxis = vAxis + (sens*vAxisInput)
		else if vAxisInput < -0.05 then
			vAxis = vAxis - (sens*vAxisInput)
		end end
		if vAxis > 0.235 then vAxis = 0.235 end
		if vAxis < -0.05 then vAxis = -0.05 end
	end
	
	-- hAxisSetpoint setting up
	mode = input.getBool(1)
	if mode then
		hAxisSetpoint = input.getNumber(3)
	else
		hAxisSetpointInput = input.getNumber(3)
		if hAxisSetpointInput > 0.05 then
			hAxisSetpoint = hAxisSetpoint + (sens*hAxisSetpointInput)
		else if hAxisSetpointInput < -0.05 then
			hAxisSetpoint = hAxisSetpoint - (sens*hAxisSetpointInput)
		end end
		if hAxisSetpoint > 0.5 then hAxisSetpoint = hAxisSetpoint - 1 end
		if hAxisSetpoint < -0.5 then hAxisSetpoint = hAxisSetpoint + 1 end
	end
	-- hAxisVariable setting up
	hAxisVariable = input.getNumber(4)
	
	-- Virtual compass setting up
	hAxisSetpointOutput = 0
	hAxisVariableOutput = 0
	--if math.abs(hAxisSetpoint-hAxisVariable) < 1 - math.abs(hAxisSetpoint-hAxisVariable) then
	if math.abs(hAxisSetpoint) > 0.25 then
		hAxisSetpointOutput = (hAxisSetpoint + 1) % 1 - 0.5
		hAxisVariableOutput = (hAxisVariable + 1) % 1 - 0.5
		isInverted = true
	else
		hAxisSetpointOutput = hAxisSetpoint
		hAxisVariableOutput = hAxisVariable
		isInverted = false
	end
	
	-- Output
	output.setNumber(1, vAxis)
	output.setNumber(2, hAxisSetpointOutput)
	output.setNumber(3, hAxisVariableOutput)
end





