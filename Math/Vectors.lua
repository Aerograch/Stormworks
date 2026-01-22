-- Vector:

---@section vector 1 VECTORCLASS
---Returns a vector object in the form {x,y,z}. x, y, z = [1], [2], [3] or azimuth elevation dist
---@param x number
---@param y number
---@param z number
---@return table
function vector(x,y,z)return{
	x or 0,y or 0,z or 0,

---@section magnitude	
---Returns the magnitude of the vector
---@param me table
---@return number
magnitude=function (me)local m=me[1]^2+me[2]^2+me[3]^2 return m==1 and 1 or math.sqrt(m)end,
---@endsection

---@section dot
---Returns the dot product a • b
---@param me table
---@param b any
---@return table
dot=function (me,b)return type(b)=="table" and me[1]*b[1]+me[2]*b[2]+me[3]*b[3]or vector(me[1]*b,me[2]*b,me[3]*b)end,
---@endsection

---@section cross
---Returns the cross product a ⨉ b
---@param me table
---@param b table
---@return table
cross=function (me,b)return vector(me[2]*b[3]-me[3]*b[2],me[3]*b[1]-me[1]*b[3],me[1]*b[2]-me[2]*b[1])end,
---@endsection

---@section add
---Returns the sum a + b
---@param me table
---@param b table
---@return table
add=function (me,b)return vector(me[1]+b[1],me[2]+b[2],me[3]+b[3])end,
---@endsection

---@section subtract
---Returns a - b
---@param me table
---@param b table
---@return table
subtract=function (me,b)return vector(me[1]-b[1],me[2]-b[2],me[3]-b[3])end,
---@endsection

---@section normalize
---Returns a unit vector, a / ||a||
---@param me table
---@return table
normalize=function (me)return me:dot(1/me:magnitude())end,
---@endsection

---@section localToGlobal
---Returns the vector a transformed from its local basis to global coordinates, bm represents the local basis
---@param me table
---@param bm table
---@return table
localToGlobal=function (me,bm)return bm[1]:dot(me[1]):add(bm[2]:dot(me[2])):add(bm[3]:dot(me[3]))end,
---@endsection

---@section globalToLocal
---Returns the vector a transformed from global coordinates to a local basis, bm represents the local basis
---@param me table
---@param bm table
---@return table
globalToLocal=function (me,bm)return vector(me:dot(bm[1]),me:dot(bm[2]),me:dot(bm[3]))end,
---@endsection

---@section axang
---Returns the vector a rotated around the axis ax, who's magnitude represents the size of the rotation in radians, left-handed
---@param me table
---@param ax table
---@return table
axang=function (me,ax)
local bi,bj=me:cross(ax):normalize(),ax:normalize()
local bk=bj:cross(bi)
bi,bk=vector(math.cos(ax:magnitude()),0,-math.sin(ax:magnitude())):localToGlobal({bi,bj,bk}),vector(math.sin(ax:magnitude()),0,math.cos(ax:magnitude())):localToGlobal(
{bi,bj,bk})
return ax:magnitude()~=0 and vector(0,ax:normalize():dot(me),ax:normalize():cross(me):magnitude()):localToGlobal({bi,bj,bk}) or me
end,
---@endsection

---@section disp
---Given the offset from the player's head to the center of the hud (headtohud), the normal vector of the face of the hud relative to the vehicle (hudnorm, normally vc(0,0,1) unless xml'd to be skewed differently), and a factor to multiply the resulting of the projection from 3d coordinates onto the 2d hud by (fact) (x and y aren't scaled with the hud's normal, i.e. with a hudnorm of vc(0,1,1) pixel y would be scaled by a factor of √2 when looking at the plane head-on, drawn as if there was no skew)
---@param me table
---@param headtohud table
---@param hudnormalize table
---@param fact number
---@return table
---@return table
disp=function (me,headtohud,hudnormalize,fact)
local t=me:dot(hudnormalize:dot(headtohud)/hudnormalize:dot(me)):subtract(headtohud)
return t[1]*fact,-t[2]*fact
end,
---@endsection

---@section dsimp
---Given a factor normally derived from FOV (fact), this returns the simple perspective projection from a 3d coordinate to the 2d screen, assuming coordinates are local to the screen with x and y representing the x and y axes of the screen
---@param me table
---@param fact number
---@return table
---@return table
dsimp=function (me,fact)
return me[1]/me[3]*fact,-me[2]/me[3]*fact
end,
---@endsection

---@section cartesianToPolar
---Converts cartesian coordinates to polar. Invert x and z before and after!
---@param me table
---@return table
cartesianToPolar = function (me)
	return vector(
		math.atan(me[1], -me[3]), ---azimuth
		math.atan(me[2], math.sqrt(me[1]^2 + me[3]^2)), ---elevation
		math.sqrt(me[1]*me[1] + me[2]*me[2] + me[3]*me[3]) ---distance
	)
end,
---@endsection

---@section polarToCartesian
---Converts polar coordinates to cartesian. Invert x and z before and after!
---@param me table
---@return table
polarToCartesian = function (me)
	return vector(
		me[3]*math.cos(me[2])*math.sin(me[1]),
		me[3]*math.sin(me[2]),
		-me[3]*math.cos(me[2])*math.cos(me[1])
	)
end,
---@endsection

---@section apply
---Applies function to all components
---@param me table
---@param func function
---@return table
apply = function (me, func)
	return vector(func(me[1]), func(me[2]), func(me[3]))
end,
---@endsection

---@section applyIndex
---Same as apply, but provides index and self to func instead of values
---@param me any
---@param func any
---@return table
applyIndex = function (me, func)
	return vector(func(me, 1), func(me, 2), func(me, 3))
end,
---@endsection

---@section isNAN
---Returns true if any of XYZ is Not A Number
---@param me table
---@return boolean
isNAN = function (me)
	return me[1] ~= me[1] or me[2] ~= me[2] or me[3] ~= me[3]
end,
---@endsection

}end
---@endsection VECTORCLASS

---@section ijkb
-- Basis:
----- Returns me vector basis in the form {i,j,k} (notated in other functions as "bm"), x, y and z are the left-handed angles around the x, y and z axes, t is an optional parameter that, when set to "aer" changes the rotation order of the function from standard physics sensor Euler angles to azimuth, elevation and roll
---@param x number
---@param y number
---@param z number
---@param t string
---@return table
function ijkb(x,y,z,t)
local sx,cx,sy,cy,sz,cz=math.sin(x),math.cos(x),math.sin(y),math.cos(y),math.sin(z),math.cos(z)
return t~="aer" and{vector(cy*cz,cy*sz,-sy),vector(sx*sy*cz-cx*sz,sx*sy*sz+cx*cz,sx*cy),vector(cx*sy*cz+sx*sz,cx*sy*sz-sx*cz,cx*cy)}or{vector(cz*cx+sz*sy*sx,-sz*cy,sz*sy*cx-cz*sx),vector(sz*cx-cz*sy*sx,cz*cy,-cz*sy*cx-sz*sx),vector(sx*cy,sy,cx*cy)}
end
---@endsection

---@section ijk
---Returns the same as ijkb, except in the form i, j, k as separate variables
---@param x number
---@param y number
---@param z number
---@param t string
function ijk(x, y, z, t)return table.unpack(ijkb(x, y, z, t))end
---@endsection

---@section fullaxang
function fullaxang(bm,me)return{bm[1]:axang(me),bm[2]:axang(me),bm[3]:axang(me)}end
---@endsection

---@section fulllocalToGlobal
---Returns the whole basis b1 transformed from its local basis to global coordinates, b2 represents the local basis
---@param b1 table
---@param b2 table
---@return table
function fulllocalToGlobal(b1,b2)
return {b1[1]:localToGlobal(b2),b1[2]:localToGlobal(b2),b1[3]:localToGlobal(b2)}
end
---@endsection

---@secton fullglobalToLocal
---Returns the whole basis b1 transformed from global coordinates to a local basis, b2 represents the local basis
---@param b1 table
---@param b2 table
---@return table
function fullglobalToLocal(b1,b2)
return {b1[1]:globalToLocal(b2),b1[2]:globalToLocal(b2),b1[3]:globalToLocal(b2)}
end
---@endsection

---@section getVector
---Returns the vector who's components are written in the property text with the name s (string), in the form xCoord,yCoord,zCoord (EX: "1,0,-3")
---@param si string
---@return table
function getVector(si)
	s=property.getText(si)
	local pi,t=1,{}
	for i=1,s:len() do
		if s:sub(i,i)=="," then
			t[#t+1]=tonumber(s:sub(pi,i-1))
			pi=i+1
		elseif i==s:len() then
			t[#t+1]=tonumber(s:sub(pi,-1))
		end
	end
	return vector(table.unpack(t))
end
---@endsection

---@section inputVector
---Gets vector from 3 channels
function inputVector(channels, input)
	return vector(input.getNumber(channels[1]), input.getNumber(channels[2]), input.getNumber(channels[3]))
end
---@endsection