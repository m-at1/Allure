--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"
local DataTypes = require "./DataTypes"

type SerDes<T> = ATypes.SerDes<T>

local function estimate(val)
	local datatype = "A"

	-- bool
	if typeof(val) == "boolean" then
		datatype = val and "K" or "L"

	-- number
	elseif typeof(val) == "number" then
		-- integer
		if val % 1 == 0 then
			-- unsigned integer
			if val >= 0 then
				if val < 2 ^ 8 then --uint8
					datatype = "C"
				elseif val < 2 ^ 16 then --uint16
					datatype = "D"
				elseif val < 2 ^ 32 then --uint32
					datatype = "E"
				end

			-- signed integer
			else
				if -val <= (2 ^ 8) / 2 then --int8
					datatype = "F"
				elseif -val <= (2 ^ 16) / 2 then --int16
					datatype = "G"
				elseif -val <= (2 ^ 32) / 2 then --int32
					datatype = "H"
				end
			end

		-- float
		else
			-- safe zone
			if 10 ^ -70 < val and val < 10 ^ 70 then --float32
				datatype = "I"
			else --float64
				datatype = "J"
			end
		end
	-- string
	elseif typeof(val) == "string" then
		--TODO
		datatype = "B"
	-- cframe
	elseif typeof(val) == "CFrame" then
		--..
		-- vector3
	elseif typeof(val) == "Vector3" then
		--..
		-- color3
	elseif typeof(val) == "Color3" then
		--..

		-- custom
	elseif typeof(val) == "table" then
		--..
	end

	return datatype
end

return {
	Read = function(buff: buffer, index: number): (SerDes<any>, number, number?)
		--warn(buff, index)
		local val = buffer.readstring(buff, index, 1)
		print(val, index)

		local length = 0

		if val == "B" then --read string length
			index += 1
			length = buffer.readi8(buff, index)
		end
		--local datatype = estimate(val)

		--print(datatype)

		return DataTypes[val], index + 1, length
	end,
	Write = function(buff: buffer, index: number, val: any)
		local datatype = estimate(val)

		buffer.writestring(buff, index, datatype)

		if datatype == "B" then
			index += 1
			buffer.writei8(buff, index, #val)
		end

		return DataTypes[datatype], index + 1
	end,
	EstimateLength = function(val: any)
		return ({
			C = 1,
			D = 2,
			E = 4,

			F = 1,
			G = 2,
			H = 4,

			I = 4,
			J = 8,

			K = 0,
			L = 0,
		})[estimate(val)]
	end,
	EstimateLengthDataType = function(datat: string)
		return ({
			C = 1,
			D = 2,
			E = 4,

			F = 1,
			G = 2,
			H = 4,

			I = 4,
			J = 8,

			K = 0,
			L = 0,
		})[datat]
	end,
	Estimate = function(val: any)
		return estimate(val)
	end,
}
