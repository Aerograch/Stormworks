pi=math.pi
pi2=pi*2
sin = math.sin
cos = math.cos
acos = math.acos
asin = math.asin
atan = math.atan
tan = math.tan
abs = math.abs
sqrt = math.sqrt
---Returns +1 when the input is greater or equal to 0, and returns -1 when it's less than 0.
---@param x number
---@return number
function sgn(x)
	return x<0 and -1 or 1
end
---It "clamps" the value x between l and u, representing the lower and upper values.
---@param x number
---@param l number
---@param u number
---@return number
function clamp(x,l,u)
	return math.min(math.max(x,l),u)
end
---It's the Pythagorean theorem in disguise.
---@param x number
---@param y number
---@return number
function len(x,y)
	return math.sqrt(x^2+y^2)
end
---Take in an angle (in radians) and return the same angle (in radians), but simplified. norm() restricts the output between 0 and pi2
---@param x number
---@return number
function norm(x)
	return x%pi2
end
---Take in an angle (in radians) and return the same angle (in radians), but simplified. norm2() restricts the output between -pi and +pi.
---@param x number
---@return number
function norm2(x)
	return (x-pi)%pi2-pi
end