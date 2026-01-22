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



g=30
g=g/60^2

--Cannon Parameters(Muzzle velocity, Drag, Lifespan)
Param={}
--Machinegun
Param[1]={800,0.025,300}
--LAC
Param[2]={1000,0.02,300}
--RAC
Param[3]={1000,0.01,300}
--HAC
Param[4]={900,0.005,600}
--Battle Cannon
Param[5]={800,0.002,3600}
--Artillery Cannon
Param[6]={700,0.001,3600}
--Bertha Cannon
Param[7]={600,0.0005,3600}
--Rocket
Param[8]={600,0.003,3600}



abs=math.abs
sin=math.sin
cos=math.cos
tan=math.tan
atan=math.atan
e=math.exp(1)
pi=math.pi
pi2=2*pi

function sgn(x)
	if x==0 then
		y=0
	else
		y=x/abs(x)
	end
	return y
end
function f(t,x,y,a,b,c,d)
	E=e^(-c*t)
	return x^2+(y+d*t-a*(1-E))^2-b^2*(1-E)^2
end
function dfdx(t,x,y,a,b,c,d)
	E=e^(-c*t)
	return 2*(y+d*t-a*(1-E))*(d-a*c*E)-b^2*c*E
end
function q(t,x,y,a,b,c,d)
	E=e^(-c*t)
	return atan(y-a*(1-E)+d*t,x)*2/pi
end
function BisectionMethod(n,x1,x2,x,y,a,b,c,d)
	error=false
	for i=1,13 do
		xm=(x1+x2)/2
		if abs(x1-x2)<0.5 then
			break
		end
		if n==0 then
			s1,s2,sm=sgn(dfdx(x1,x,y,a,b,c,d)),sgn(dfdx(x2,x,y,a,b,c,d)),sgn(dfdx(xm,x,y,a,b,c,d))
		else
			s1,s2,sm=sgn(f(x1,x,y,a,b,c,d)),sgn(f(x2,x,y,a,b,c,d)),sgn(f(xm,x,y,a,b,c,d))
		end
		if s1==sm and s2==sm then
			error=true
			break
		else
			if s1==sm then
				x1=xm
			elseif s2==sm then
				x2=xm
			else
				error=true
				break
			end
		end
	end
	return xm,error
end


function onTick()
	Xk,Yk,Type=input.getNumber(1),input.getNumber(2),input.getNumber(11)
	Mode=input.getBool(1)
	
	if Type==0 or Xk<=0 then
		Time1,Angle1,Error1=0,0,false
		Time2,Angle2,Error2=0,0,false
	else
		v0,cd,tl=Param[Type][1]/60,Param[Type][2],Param[Type][3]
		Ak,Bk,Ck,Dk=g/cd^2,v0/cd,cd,g/cd
		X,Y,A,B,C,D=Xk/10^3,Yk/10^3,Ak/10^3,Bk/10^3,Ck,Dk/10^3
		
		t0,Error0=BisectionMethod(0,0,3600,X,Y,A,B,C,D)
		if Error0 then
			Time,Angle,Error=0,0,true
		else
			if not Mode then
				tStart1,tStart2=0,t0
			else
				tStart1,tStart2=t0,tl
			end
			
			Time,Error=BisectionMethod(1,tStart1,tStart2,X,Y,A,B,C,D)
			if Error then
				Angle=0
			else
				Angle=q(Time,X,Y,A,B,C,D)
			end
			if Time>tl then Error=true end
		end
	end

	output.setNumber(1,Angle)
	output.setNumber(2,Time)
	output.setBool(1,Error)
end



