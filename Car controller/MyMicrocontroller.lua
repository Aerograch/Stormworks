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
---13 - speed
---bool
---21 - Ignition
---22 - Parking break
---23 - Manual
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
---3 - IsGamepad
---

controller = {
    throttle = 0,
    steering = 0,
    breaking = 0,
    gamepad = false,
    gearUp = false,
    gearDown = false
}

car = {
    wheelRPS = 0,
    engineRPS = 0,
    speed = 0,
    gearShiftDelay = 15,
    gear = 1,
    manual = false,
    ignition = false,
    parkingBreak = false
}



function onTick()
    controller.gamepad = input.getNumber(property.getNumber("Gamepad switch button"))
    controller.gearUp = input.getNumber(property.getNumber("Gear up button"))
    controller.gearDown = input.getNumber(property.getNumber("Dear down button"))

    car.wheelRPS = input.getNumber(11)
    car.engineRPS = input.getNumber(12)
    car.speed = input.getNumber(13)
    car.ignition = input.getBool(21)
    car.parkingBreak = input.getBool(22) or input.getBool(property.getNumber("Keyboard breaking button(trigger = 31)"))
    car.manual = input.getBool(23)

    if controller.gamepad then
        controller.throttle = input.getNumber(property.getNumber("Gamepad Throttle Axis"))
        controller.throttle = (controller.throttle - 1)/-2
        controller.breaking = input.getNumber(property.getNumber("Gamepad Breaking Axis"))
        controller.breaking = (controller.breaking - 1)/-2
        controller.steering = input.getNumber(property.getNumber("Gamepad Steering Axis"))
    else
        controller.throttle = clamp(input.getNumber(property.getNumber("Keyboard Throttle Axis")), 0, 1)
        controller.breaking = clamp(input.getNumber(property.getNumber("Keyboard Throttle Axis"))*-1, 0, 1)
        controller.steering = input.getNumber(property.getNumber("Keyboard Steering Axis"))
    end

    ---Clutch handling



    ---Automatic gear box

    if car.gearShiftDelay > 0 then
        car.gearShiftDelay = car.gearShiftDelay - 1
    end

    if car.manual and car.gearShiftDelay == 0 then
        if controller.gearUp and car.gear < property.getNumber("Number of gears") then
            car.gear = car.gear + 1
                car.gearShiftDelay = 15
        end
        if (controller.gearDown or car.engineRPS < 3) and car.gear > 1 then
            car.gear = car.gear - 1
                car.gearShiftDelay = 15
        end
    else
        if car.gearShiftDelay == 0 then
            if car.engineRPS > 12 and car.gear < property.getNumber("Number of gears") then
                car.gear = car.gear + 1
                car.gearShiftDelay = 15
            end
            if car.engineRPS < 6 and car.gear > 1 then
                car.gear = car.gear - 1
                car.gearShiftDelay = 15
            end
        end
    end

    output.setNumber(3, car.gear)
end




