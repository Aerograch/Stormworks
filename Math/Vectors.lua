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
---@param a table
---@return number
magnitude=function (a)local m=a[1]^2+a[2]^2+a[3]^2 return m==1 and 1 or math.sqrt(m)end,
---@endsection

---@section dot
---Returns the dot product a • b
---@param a table
---@param b any
---@return table
dot=function (a,b)return type(b)=="table" and a[1]*b[1]+a[2]*b[2]+a[3]*b[3]or vector(a[1]*b,a[2]*b,a[3]*b)end,
---@endsection

---@section cross
---Returns the cross product a ⨉ b
---@param a table
---@param b table
---@return table
cross=function (a,b)return vector(a[2]*b[3]-a[3]*b[2],a[3]*b[1]-a[1]*b[3],a[1]*b[2]-a[2]*b[1])end,
---@endsection

---@section add
---Returns the sum a + b
---@param a table
---@param b table
---@return table
add=function (a,b)return vector(a[1]+b[1],a[2]+b[2],a[3]+b[3])end,
---@endsection

---@section subtract
---Returns a - b
---@param a table
---@param b table
---@return table
subtract=function (a,b)return vector(a[1]-b[1],a[2]-b[2],a[3]-b[3])end,
---@endsection

---@section normalize
---Returns a unit vector, a / ||a||
---@param a table
---@return table
normalize=function (a)return a:dot(1/a:magnitude())end,
---@endsection

---@section localToGlobal
---Returns the vector a transformed from its local basis to global coordinates, bm represents the local basis
---@param a table
---@param bm table
---@return table
localToGlobal=function (a,bm)return bm[1]:dot(a[1]):add(bm[2]:dot(a[2])):add(bm[3]:dot(a[3]))end,
---@endsection

---@section globalToLocal
---Returns the vector a transformed from global coordinates to a local basis, bm represents the local basis
---@param a table
---@param bm table
---@return table
globalToLocal=function (a,bm)return vector(a:dot(bm[1]),a:dot(bm[2]),a:dot(bm[3]))end,
---@endsection

---@section axang
---Returns the vector a rotated around the axis ax, who's magnitude represents the size of the rotation in radians, left-handed
---@param a table
---@param ax table
---@return table
axang=function (a,ax)
local bi,bj=a:cross(ax):normalize(),ax:normalize()
local bk=bj:cross(bi)
bi,bk=vector(math.cos(ax:magnitude()),0,-math.sin(ax:magnitude())):localToGlobal({bi,bj,bk}),vector(math.sin(ax:magnitude()),0,math.cos(ax:magnitude())):localToGlobal(
{bi,bj,bk})
return ax:magnitude()~=0 and vector(0,ax:normalize():dot(a),ax:normalize():cross(a):magnitude()):localToGlobal({bi,bj,bk}) or a
end,
---@endsection

---@section disp
---Given the offset from the player's head to the center of the hud (headtohud), the normal vector of the face of the hud relative to the vehicle (hudnorm, normally vc(0,0,1) unless xml'd to be skewed differently), and a factor to multiply the resulting of the projection from 3d coordinates onto the 2d hud by (fact) (x and y aren't scaled with the hud's normal, i.e. with a hudnorm of vc(0,1,1) pixel y would be scaled by a factor of √2 when looking at the plane head-on, drawn as if there was no skew)
---@param a table
---@param headtohud table
---@param hudnormalize table
---@param fact number
---@return table
---@return table
disp=function (a,headtohud,hudnormalize,fact)
local t=a:dot(hudnormalize:dot(headtohud)/hudnormalize:dot(a)):subtract(headtohud)
return t[1]*fact,-t[2]*fact
end,
---@endsection

---@section dsimp
---Given a factor normally derived from FOV (fact), this returns the simple perspective projection from a 3d coordinate to the 2d screen, assuming coordinates are local to the screen with x and y representing the x and y axes of the screen
---@param a table
---@param fact number
---@return table
---@return table
dsimp=function (a,fact)
return a[1]/a[3]*fact,-a[2]/a[3]*fact
end,
---@endsection

---@section cartesianToPolar
---Converts cartesian coordinates to polar. Invert x and z before and after!
---@param a table
---@return table
cartesianToPolar = function (a)
	return vector(
		math.atan(a[1], -a[3]), ---azimuth
		math.atan(a[2], math.sqrt(a[1]^2 + a[3]^2)), ---elevation
		math.sqrt(a[1]*a[1] + a[2]*a[2] + a[3]*a[3]) ---distance
	)
end,
---@endsection

---@section polarToCartesian
---Converts polar coordinates to cartesian. Invert x and z before and after!
---@param a table
---@return table
polarToCartesian = function (a)
	return vector(
		a[3]*math.cos(a[2])*math.sin(a[1]),
		a[3]*math.sin(a[2]),
		-a[3]*math.cos(a[2])*math.cos(a[1])
	)
end,
---@endsection

---@section apply
---Applies function to all components
---@param a table
---@param func function
---@return table
apply = function (a, func)
	return vector(func(a[1]), func(a[2]), func(a[3]))
end,
---@endsection

---@section applyIndex
---Same as apply, but provides index and self to func instead of values
---@param a any
---@param func any
---@return table
applyIndex = function (a, func)
	return vector(func(a, 1), func(a, 2), func(a, 3))
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
----- Returns a vector basis in the form {i,j,k} (notated in other functions as "bm"), x, y and z are the left-handed angles around the x, y and z axes, t is an optional parameter that, when set to "aer" changes the rotation order of the function from standard physics sensor Euler angles to azimuth, elevation and roll
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
function fullaxang(bm,a)return{bm[1]:axang(a),bm[2]:axang(a),bm[3]:axang(a)}end
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