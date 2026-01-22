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
ln = math.log
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

---@section RollingAverage
---Initialises RollingAverage
---@param maxValuesAmount number
---@return table
function RollingAverage(maxValuesAmount)
	return {
		values = {},
		max = maxValuesAmount,
		index = 0,
		---Adds value to average and returns current average
		---@param self table
		---@param value number
		---@return number
		addValue = function (self, value)
			self.index = (self.index % self.max) + 1
			self.values[self.index] = value
			local sum = 0
			for i = 1, #self.values, 1 do
				sum = sum + self.values[i]
			end
			return sum / #self.values
		end
	}
end
---@endsection

---@section binarySearch
---Performs binary search up to |result - tgtPoint| < tgtDelta
---@param min number
---@param max number
---@param check function
---@param tgtDelta number
---@param tgtPoint number
---@param checkFunctionStaticArguments table
---@return number
function binarySearch(min, max, check, tgtDelta, tgtPoint, checkFunctionStaticArguments)
    delta = 0
    iterationsLeft = 50
	checkFunctionStaticArguments = checkFunctionStaticArguments or {}
    repeat
        mid = (max+min) / 2
        result = check(mid, checkFunctionStaticArguments)
        delta = math.abs(result-tgtPoint)
        if result-tgtPoint < 0 then
            min = mid
        else
            max = mid
        end
        iterationsLeft = iterationsLeft - 1
        if iterationsLeft == 0 then break end
    until delta < tgtDelta
    return mid
end
---@endsection

---@section RollingVectorAverage
require("Math.Vectors")

---Initialises RollingVectorAverage
---@param maxValuesAmount number
---@return table
function RollingVectorAverage(maxValuesAmount)
	return {
		xValues = {},
		yValues = {},
		zValues = {},
		max = maxValuesAmount,
		index = 0,
		---Adds vector to average and returns current average vector
		---@param self table
		---@param vectorValue table
		---@return table
		addValue = function (self, vectorValue)
			self.index = (self.index % self.max) + 1
			self.xValues[self.index] = vectorValue[1]
			self.yValues[self.index] = vectorValue[2]
			self.zValues[self.index] = vectorValue[3]

			local sumX = 0
			for i = 1, #self.xValues, 1 do
				sumX = sumX + self.xValues[i]
			end

			local sumY = 0
			for i = 1, #self.yValues, 1 do
				sumY = sumY + self.yValues[i]
			end

			local sumZ = 0
			for i = 1, #self.zValues, 1 do
				sumZ = sumZ + self.zValues[i]
			end

			return vector(
				sumX / #self.xValues,
				sumY / #self.yValues,
				sumZ / #self.zValues
			)
		end
	}
end
---@endsection