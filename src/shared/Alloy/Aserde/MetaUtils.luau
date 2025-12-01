--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"
local ExpandBuffer = require "./ExpandBuffer"
local MergeBuffer = require "./MergeBuffer"

type SerDes<T> = ATypes.SerDes<T>

local MetaUtils

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
		datatype = "B"

	--color3
	elseif typeof(val) == "Color3" then
		datatype = "N"

	-- table
	elseif typeof(val) == "table" then
		datatype = "M"

	-- cframe
	elseif typeof(val) == "CFrame" then
		datatype = "S"

	--vector3
	elseif typeof(val) == "Vector3" then
		datatype = "O"

	--vector3int16
	elseif typeof(val) == "Vector3int16" then
		datatype = "P"

	--vector2
	elseif typeof(val) == "Vector2" then
		datatype = "Q"

	--vector2int16
	elseif typeof(val) == "Vector2int16" then
		datatype = "R"
	end

	return datatype
end

MetaUtils = {
	SpecialType = { __specialtype = 1 },
	handleSpecialType = function(val: any, datatype: any)
		if typeof(val) == "table" and val[MetaUtils.SpecialType] then
			datatype = val[MetaUtils.SpecialType :: any]
			val = val[1]
		end
		return val, datatype
	end,
	NextIndex = function(buff: buffer, index: number)
		if index >= buffer.len(buff) - 1 then
			return ExpandBuffer(buff, index + 1), index
		end
		return buff, index
	end,
	Merge = MergeBuffer,
	Estimate = estimate,
	EstimateLength = function(val: any)
		return ({
			B = 2, --placeholder, impossible case

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
			B = 2, --placeholder, impossible case

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
}

return MetaUtils
