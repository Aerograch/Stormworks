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
require("Types.List")
require("Types.Stack")


function Track(position)
    return {
    position = position,
    assignOrCreate = function (me, targets, counter, pos)
        possibleTargets = {}
        for i = 1, #targets.list do
            difference = abs(me.position:magnitude() - targets.list[i].position:magnitude())
            if difference < targets.list[i].velocity:magnitude() * 4 * (counter-targets.list[i].lastUpdated+1) then
                possibleTargets[#possibleTargets+1] = i
            elseif targets.list[i].filter.k < targets.list[i].filter.k_max and difference < 17 * (counter-targets.list[i].lastUpdated+1) * pos:magnitude()/10 then
                possibleTargets[#possibleTargets+1] = i
            end
        end
        min = 999999999
        id = 0
        for i = 1, #possibleTargets do
            if targets.list[possibleTargets[i]].filter.k < targets.list[possibleTargets[i]].filter.k_max then
                difference = me.position:subtract(targets.list[possibleTargets[i]].position):magnitude()
            else
                difference = me.position:subtract(targets.list[possibleTargets[i]].position:add(targets.list[possibleTargets[i]].velocity:dot(counter-targets.list[i].lastUpdated+1))):magnitude()
            end
            if difference < min then
                min = difference
                id = possibleTargets[i]
            end
        end
        if id ~= 0 then
            targets.list[id]:update(me.position, counter)
        else
            targets:add(Target(me, counter))
        end    
        return {
            difference = abs(me.position:magnitude() - targets.list[1].position:magnitude()),
            condition1 = targets.list[1].velocity:magnitude(),
            condition2 = possibleTargets[1] ~= nil and me.position:subtract(targets.list[possibleTargets[1]].position:add(targets.list[possibleTargets[1]].velocity:dot(counter-targets.list[1].lastUpdated+1))):magnitude() or -69,
            condition3 = 17 * (counter-targets.list[1].lastUpdated+1) * pos:magnitude()/10 or -69,
        }
    end
    }
end

function Target(track, counter)
    return{
    positionStack = Stack(),
    position = track.position,
    velocity = vector(0,0,0),
    filter = ABVectorFilter(100),
    lastUpdated = counter,
    lifeTime = 0,
    update = function (me, newPos, counter)
        newPos = me.filter:step(newPos, counter-me.lastUpdated)
        me.positionStack:add({newPos, counter})
        if me.positionStack:count() > 40 then
            me.positionStack:remove()
        end
        me.velocity = newPos:subtract(me.positionStack.values[1][1]):dot(1/(counter-me.positionStack.values[1][2]) ~= 0/0 and 1 or 1/(counter-me.positionStack.values[1][2]))
        me.lastUpdated = counter
        me.position = newPos
        me.lifeTime = 0
    end,
    tick = function (me)
        me.lifeTime = me.lifeTime + 1
    end,
    }
end

gps = vector()
targets = List({})
counter = 0
tracks = {}
zoom = 1
debug = {}
function onTick()
    debug = {}
    counter = counter + 1
    tracks = {}
    gps = vector(input.getNumber(4), input.getNumber(8), input.getNumber(12))
    vehicleBasis = ijkb(input.getNumber(16), input.getNumber(20), input.getNumber(24))
    zoom = input.getNumber(28)
    i = 1
    while input.getBool(i) do
        target = vector(input.getNumber((i-1)*4+1), input.getNumber((i-1)*4+2), input.getNumber((i-1)*4+3))
        temp = ijkb(target[2]*pi*2, target[3]*pi*2, 0, "aer")[3]
        localTarget = temp:dot(target[1])
        globalTarget = localTarget:localToGlobal(vehicleBasis)
        globalTarget = globalTarget:add(gps)
        if not globalTarget:isNAN() then
            tracks[#tracks+1] = Track(globalTarget)
        end
        i = i + 1
    end

    for i = 1, #tracks do
        debug[1] = tracks[i]:assignOrCreate(targets, counter, gps)
    end

    deletionIds = {}
    for i = 1, #targets.list do
        targets.list[i]:tick()
        if targets.list[i].lifeTime > 600 then
            deletionIds[#deletionIds+1] = i
        end
    end
    for i = #deletionIds, 1, -1 do
        targets:remove(deletionIds[i])
    end
end

function onDraw()
    screen.setColor(255,255,255)
    screen.drawMap(gps[1], gps[3], zoom)
    if targets.list[1] ~= nil then
        screen.drawText(5, 5, targets.list[1].position[1])
        screen.drawText(5, 15, targets.list[1].position[3])
        screen.drawText(5, 25, counter-targets.list[1].lastUpdated)
        screen.drawText(5, 35, debug[1] ~= nil and debug[1].difference or -69)
        screen.drawText(5, 45, debug[1] ~= nil and debug[1].condition1 or -69)
        screen.drawText(5, 55, debug[1] ~= nil and debug[1].condition2 or -69)
        screen.drawText(5, 65, debug[1] ~= nil and debug[1].condition3 or -69)
    end
    screen.setColor(200,0,0)
    
    for i = 1, #targets.list do
        tgtX, tgtY = map.mapToScreen(gps[1], gps[3], zoom, screen.getWidth(), screen.getHeight(), targets.list[i].position[1], targets.list[i].position[3])
        screen.drawCircleF(tgtX, tgtY, 1.5)
        predictedCords = targets.list[i].position:add(targets.list[i].velocity:dot(30))
        predX, predY = map.mapToScreen(gps[1], gps[3], zoom, screen.getWidth(), screen.getHeight(), predictedCords[1], predictedCords[3])
        screen.drawLine(tgtX, tgtY, predX, predY)
    end
end



