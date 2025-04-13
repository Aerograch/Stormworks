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

function Contact(azimuth, elevation, distance)
    return {
        azimuth = azimuth,
        elevation = elevation,
        distance = distance
    }
end

function Target(x, y, z)
    return {
        x = x,
        y = y,
        z = z,
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

--math
function Euler2Matrix(v)
    ax,ay,az=v[1],v[2],v[3]
    m11=cos(ay)*cos(az)
    m12=cos(ax)*cos(ay)*sin(az)+sin(ax)*sin(ay)
    m13=sin(ax)*cos(ay)*sin(az)-cos(ax)*sin(ay)
    m21=-sin(az)
    m22=cos(ax)*cos(az)
    m23=sin(ax)*cos(az)
    m31=sin(ay)*cos(az)
    m32=cos(ax)*sin(ay)*sin(az)-sin(ax)*cos(ay)
    m33=sin(ax)*sin(ay)*sin(az)+cos(ax)*cos(ay)
    return {{m11,m12,m13},{m21,m22,m23},{m31,m32,m33}}
end
function InvM(m)
    im={{},{},{}}
    for i=1,3 do
        for j=1,3 do
            im[i][j]=m[j][i]
        end
    end
    return im
end
function VTrans(m,v)
    tv={}
    for i=1,3 do
        tv[i]=0
        for j=1,3 do
            tv[i]=tv[i]+v[j]*m[j][i]
        end
    end
    return tv
end
--math end


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
    angle = 0
}

ship = {
    x = 0,
    y = 0,
    z = 0,
    matrix = 0,
}

screenParams = {
    width = 0,
    height = 0
}

targets = {
    ship = List(),
    global = List()
}

contacts = List()

sin = math.sin
cos = math.cos
xxx = 0
yyy = 0
distance = 0

function onTick()

    if screenParams.width == 0 then
        return
    end

    targets.ship = List()
    contacts = List()

    ship.x = input.getNumber(17)
    ship.y = input.getNumber(19)
    ship.z = input.getNumber(18)
    ship.matrix = Euler2Matrix({input.getNumber(20), input.getNumber(22), input.getNumber(21)})

    for i = 1, 4 do
        if input.getBool(i) then
            contacts.add(contacts,
                Contact(input.getNumber(i+1),
                input.getNumber(i+2),
                input.getNumber(i)))
        end
    end

    if #contacts > 0 then
        for i = 1, #contacts do
            contact = contacts[i]
            --was taken from https://stackoverflow.com/questions/20769011/converting-3d-polar-coordinates-to-cartesian-coordinates
            x = contact.distance * sin(contact.elevation) * cos(contact.azimuth)
            y = contact.distance * sin(contact.elevation) * sin(contact.azimuth)
            xxx = x
            yyy = y
            distance = contact.distance
            z = contact.distance * cos(contact.elevation)
            targets.ship.add(targets.ship, Target(x,y,z))
        end

        for i = 1, #targets.ship do
            target = targets.ship[i]
            transformedXYZ = VTrans(ship.matrix, {target.z, target.y, target.x})
            targets.global.add(targets.global, Target(transformedXYZ[2] + ship.x, transformedXYZ[3] + ship.y, transformedXYZ[1] + ship.z))
        end
    end

    removal = {}
    for i = 1, #targets.global do
        targets.global[i].increment(targets.global[i])
        if targets.global[i].time >= 60 then
            removal[#removal+1] = i
        end
    end
    for i = #removal, 1, -1 do
        targets.global.remove(targets.global, i)
    end

    if #targets.global > 0 then
        output.setNumber(1, targets.global[1].x)
        output.setNumber(2, targets.global[1].y)
        output.setNumber(3, targets.global[1].z)
    end
end

function onDraw()
    screenParams.height = screen.getHeight()
    screenParams.width = screen.getWidth()

    screen.setColor(5,5,5)
    screen.drawClear()

    screen.setColor(255, 0, 0)
    screen.drawMap(ship.x, ship.y, 3)
    if #targets.global > 0 then
        screen.drawText(2,2,string.format("x: %f, y: %f, z: %d", xxx,  yyy,  math.floor(distance)))--math.floor(targets.global[1].x), math.floor(targets.global[1].y), math.floor(targets.global[1].z)))
    end

    for i = 1, #targets.global do
        target = targets.global[i]
        x, y = map.mapToScreen(ship.x, ship.y, 3, screen.getWidth(), screen.getHeight(), target.x, target.y)
        screen.drawCircleF(x,y,1)
    end
end



