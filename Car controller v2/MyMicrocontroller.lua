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

require("Math.Basics")

---Input
---Seat:
---num 1-8 Controll Axis
---num 9,10 - Look x/y
---Bool 1-20 - buttons
---Bool 31 - trigger
---Bool 32 - occupied
---Other:
---num
---11 - Wheel RPS
---12 - Engine RPS
---bool
---21 - Ignition
---22 - Parking break
---
---Output
---num
---1 - Clutch
---2 - Engine throttle
---3 - Gear
---4 - Breaks
---5 - Steering
---bool
---1 - Starter
---2 - Reverse

constants = {
    gamepadSwitchButton = property.getNumber("Gamepad switch"),
    gamepadForwardAxis = property.getNumber("Gamepad Forward Axis"),
    gamepadRearAxis = property.getNumber("Gamepad Backward Axis"),
    gamepadSteeringAxis = property.getNumber("Gamepad Steering Axis"),
    keyboardThrottleAxis = property.getNumber("Keyboard Throttle Axis"),
    keyboardSteeringAxis = property.getNumber("Keyboard Steering Axis"),
    gearUpButton = property.getNumber("Gear up button"),
    gearDownButton = property.getNumber("Dear down button"),
    handBreakingButton = property.getNumber("Keyboard breaking button"),
    manualModeSwitch = property.getNumber("Semi-manual switch button"),

    gearNumber = property.getNumber("Number of gears"),
    topRpsThreshold = property.getNumber("Top rps threshold"),
    bottomRpsThreshold = property.getNumber("Bottom rps threshold"),
    clutchTurnoverTimeframe = property.getNumber("Clutch turnover timeframe"),

    isModular = property.getBool("Is modular engine"),
    smoothBreaking = property.getBool("Smooth breaking"),
    rpsLimiter = property.getBool("Limit RPS")
}

controller = {
    forward = 0,
    steering = 0,
    back = 0,
    gamepad = false,
    gearUp = false,
    gearDown = false
}

car = {
    throttle = 0,
    wheelRPS = 0,
    engineRPS = 0,
    gearShiftDelay = 15,
    reverseSwitchDelay = 60,
    gear = 1,
    clutch = 1,
    brakes = 0,
    manual = false,
    reverse = false,
    ignition = false,
    starter = false,
    parkingBreak = false
}



function onTick()
    ---Inputs

    controller.gamepad = input.getBool(constants.gamepadSwitchButton)
    controller.gearUp = input.getNumber(constants.gearUpButton)
    controller.gearDown = input.getNumber(constants.gearDownButton)

    car.wheelRPS = math.abs(input.getNumber(11))
    car.engineRPS = input.getNumber(12)
    car.ignition = input.getBool(21)
    car.parkingBreak = input.getBool(22) or input.getBool(constants.handBreakingButton)
    car.manual = input.getBool(constants.manualModeSwitch)

    if controller.gamepad then
        controller.forward = input.getNumber(constants.gamepadForwardAxis)
        controller.forward = (controller.forward - 1)/-2
        controller.back = input.getNumber(constants.gamepadRearAxis)
        controller.back = (controller.back - 1)/-2
        controller.steering = input.getNumber(constants.gamepadSteeringAxis)
    else
        controller.forward = clamp(input.getNumber(constants.keyboardThrottleAxis), 0, 1)
        controller.back = clamp(input.getNumber(constants.keyboardThrottleAxis)*-1, 0, 1)
        controller.steering = input.getNumber(constants.keyboardSteeringAxis)
    end

    ---Throttle, reverse and breaking

    if car.wheelRPS < 0.1 then
        car.reverseSwitchDelay = math.max(0, car.reverseSwitchDelay-1)
    else
        car.reverseSwitchDelay = 60
    end

    if car.wheelRPS < 0.1 and controller.forward > 0.05 and car.reverseSwitchDelay == 0 then
        car.reverse = false
    elseif car.wheelRPS < 0.1 and controller.back > 0.05 and car.reverseSwitchDelay == 0 then
        car.reverse = true
    end

    if car.reverse then
        car.throttle = clamp((controller.back-0.05)/0.95, 0, 1)
        if constants.smoothBreaking then
            car.brakes = clamp((controller.forward-0.05)/0.95, 0, 1) > 0 and math.min(1, car.brakes + 0.02) or 0
        else
            car.brakes = clamp((controller.forward-0.05)/0.95, 0, 1)
        end
    else
        if constants.smoothBreaking then
            car.brakes = clamp((controller.back-0.05)/0.95, 0, 1) > 0 and math.min(1, car.brakes + 0.02) or 0
        else
            car.brakes = clamp((controller.back-0.05)/0.95, 0, 1)
        end
        car.throttle = clamp((controller.forward-0.05)/0.95, 0, 1)
    end

    if car.parkingBreak then
        car.brakes = 1
    end
    if not constants.isModular and constants.rpsLimiter then
        car.throttle = car.throttle - clamp((car.engineRPS-constants.topRpsThreshold)/4, 0, 1)
    end

    ---Automatic gear box

    if car.gearShiftDelay > 0 then
        car.gearShiftDelay = car.gearShiftDelay - 1
    end

    if car.manual and car.gearShiftDelay == 0 then
        if controller.gearUp and car.gear < constants.gearNumber then
            car.gear = car.gear + 1
                car.gearShiftDelay = 15
        end
        if (controller.gearDown or car.engineRPS < 3) and car.gear > 1 then
            car.gear = car.gear - 1
                car.gearShiftDelay = 15
        end
    else
        if car.gearShiftDelay == 0 then
            if car.engineRPS > constants.topRpsThreshold and car.gear < constants.gearNumber then
                car.gear = car.gear + 1
                car.gearShiftDelay = 15
            end
            if car.engineRPS < constants.bottomRpsThreshold and car.gear > 1 then
                car.gear = car.gear - 1
                car.gearShiftDelay = 15
            end
        end
    end

    ---Clutch and idling handling
    
    if car.parkingBreak or (car.wheelRPS < 1 and car.throttle <= 0.05) then
        car.clutch = math.max(0, car.clutch-(1/constants.clutchTurnoverTimeframe))
        car.throttle = constants.isModular and 0 or (6-car.engineRPS)/2
    else
        car.clutch = math.min(1, car.clutch+(1/constants.clutchTurnoverTimeframe))
    end

    ---Starter
    
    if car.ignition and car.engineRPS < 2 then
        car.starter = true
    else
        car.starter = false
    end

    if not car.ignition then
        car.throttle = 0
    end

    ---Outputs

    output.setNumber(1, car.clutch)
    output.setNumber(2, car.throttle)
    output.setNumber(3, car.gear)
    output.setNumber(4, car.brakes)
    output.setNumber(5, controller.steering)

    output.setBool(1, car.starter)
    output.setBool(2, car.reverse)

    ---Debug
    
    output.setNumber(6, car.wheelRPS)
    output.setNumber(7, controller.forward)
    output.setNumber(8, controller.back)
end






