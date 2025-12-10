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

scan = false
scanning = false
scanCounter = 0
tracks = {}
terminalGuidance = false
yList = {}

targetDetected = false
launched = false
cordsSaved = false
cords = vector()
function onTick()
    pos = vector(input.getNumber(1), input.getNumber(2), input.getNumber(3))
    vehicleBasis = ijkb(input.getNumber(4), input.getNumber(5), input.getNumber(6))
    launched = input.getBool(32)
    if launched and not cordsSaved then
        cords = vector(input.getNumber(31), 20, input.getNumber(32))
        cordsSaved = true
    end

    distanceToTarget = pos:subtract(cords):magnitude()

    if launched and cordsSaved and distanceToTarget<property.getNumber("Search radar range") and distanceToTarget>property.getNumber("Lock radar range") and not scanning then
        scan = false
        scanning = true
        tracks = {}
        anyTargetDetected = false
    end

    if launched and cordsSaved and distanceToTarget<property.getNumber("Lock radar range") then
        terminalGuidance = true
    end

    if scanning then
        scanCounter = scanCounter + 1
        if input.getBool(1) then
            target = vector(input.getNumber(7), input.getNumber(8), input.getNumber(9))
            temp = ijkb(target[2]*pi*2, target[3]*pi*2, 0, "aer")[3]
            localTarget = temp:dot(target[1])
            globalTarget = localTarget:localToGlobal(vehicleBasis)
            targetGPS = globalTarget:add(pos)
            if localTarget:magnitude() > 20 then
                tracks[#tracks+1] = targetGPS
            end
            anyTargetDetected = true
        end
    end
    if scanning and scanCounter == 317 then
        scanning = false
        scanCounter = 0
        minMagnitude = 9999999999999
        minTrack = cords
        for i = 1, #tracks do
            if tracks[i]:subtract(cords):magnitude() < minMagnitude then
                minMagnitude = tracks[i]:magnitude()
                minTrack = tracks[i]
            end
        end
        lastTrackCount = #tracks
        if 2000 > abs(cords:magnitude() - minTrack:magnitude())
        then
            cords = minTrack
        end
    end

    if terminalGuidance then
        if input.getBool(2) then
            target = vector(input.getNumber(10), input.getNumber(11), input.getNumber(12))
            temp = ijkb(target[2]*pi*2, target[3]*pi*2, 0, "aer")[3]
            localTarget = temp:dot(target[1])
            globalTarget = localTarget:localToGlobal(vehicleBasis)
            tgtPos = globalTarget:add(pos)
            if localTarget:magnitude() > 5 and tgtPos:subtract(cords):magnitude() < 200 then
                yList[#yList+1] = tgtPos[2]
                sum = 0
                for i = 1, #yList do
                    sum = yList[i] + sum
                end
                tgtPos[2] = sum/#yList
                lastUpdated = counter
                cords = tgtPos
            end
        end
    end


    
    targetCords = cords
    adjustedCords = pos:subtract(targetCords)
    localCords = adjustedCords:globalToLocal(vehicleBasis)
    targetingCords = localCords:normalize()
    vehicleVelocity = vector(input.getNumber(20), input.getNumber(21), input.getNumber(22)):normalize()
    verticalDeviation = acos(vector(targetingCords[2], targetingCords[3]):dot(vector(vehicleVelocity[2], vehicleVelocity[3])) / (vector(targetingCords[2], targetingCords[3]):magnitude()*vector(vehicleVelocity[2], vehicleVelocity[3]):magnitude()))
    horizontalDeviation = acos(vector(targetingCords[1], targetingCords[3]):dot(vector(vehicleVelocity[1], vehicleVelocity[3])) / (vector(targetingCords[1], targetingCords[3]):magnitude()*vector(vehicleVelocity[1], vehicleVelocity[3]):magnitude()))
    
    if targetingCords[3] > 0 then
        targetingCords[1] = targetingCords[1] + 1*sgn(targetingCords[1])
    end
    --targetCords:cartesianToPolar()
    output.setNumber(1, horizontalDeviation ~= horizontalDeviation and 0 or horizontalDeviation)
    output.setNumber(2, verticalDeviation ~= verticalDeviation and 0 or verticalDeviation)
    output.setNumber(3, targetingCords[3] ~= targetingCords[3] and 0 or targetingCords[3])
    output.setNumber(4, cords[1])
    output.setNumber(5, cords[2])
    output.setNumber(6, cords[3])
    output.setNumber(7, vector(pos[1], 0, pos[3]):subtract(vector(cords[1], 0, cords[3])):magnitude())

    output.setBool(1, scanning)
    output.setBool(2, terminalGuidance)
    

end



