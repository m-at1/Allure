--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"
local DataTypes = require "./DataTypes"
local MetaUtils = require "./MetaUtils"

type SerDes<T> = ATypes.SerDes<T>

return {
	Read = function(buff: buffer, index: number): (SerDes<any>, number, number?)
		local val = buffer.readstring(buff, index, 1)

		return DataTypes[val], index + 1
	end,
	Write = function(buff: buffer, index: number, val: any)
		local datatype = MetaUtils.Estimate(val)

		val, datatype = MetaUtils.handleSpecialType(val, datatype)

		buff = MetaUtils.NextIndex(buff, index)

		buffer.writestring(buff, index, datatype)

		return DataTypes[datatype], index + 1, buff
	end,
	GetSer = function(datatype: string)
		return DataTypes[datatype]
	end,
	EstimateLength = MetaUtils.EstimateLength,
	EstimateLengthDataType = MetaUtils.EstimateLengthDataType,
	Estimate = MetaUtils.Estimate,
}
