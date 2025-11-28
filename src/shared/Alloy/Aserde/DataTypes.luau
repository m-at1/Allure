--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"
local MetaUtils = require "./MetaUtils"

type SerDes<T> = ATypes.SerDes<T>

local DataTypes = nil

local NextIndex = MetaUtils.NextIndex

DataTypes = {

	B = {
		Ser = function(buff: buffer, index: number, val: string)
			--write u8 length
			buffer.writeu8(buff, index, #val)
			buff, index = NextIndex(buff, index + 1)
			--write string
			buff = NextIndex(buff, index + #val)
			buffer.writestring(buff, index, val)
			return buff, index + #val
		end,
		Des = function(buff: buffer, index: number)
			local length = buffer.readu8(buff, index)
			index += 1

			return buffer.readstring(buff, index, length), index + length
		end,
	} :: SerDes<string>,

	A = {
		Ser = function(buff: buffer, index: number, val: {})
			--write number of pairs

			buff, index = NextIndex(buff, index)

			buffer.writeu8(buff, index, #val)
			buff, index = NextIndex(buff, index + 1)

			--write key-value pairs
			for key, value in val do
				--key
				local keytype = MetaUtils.Estimate(key)
				buffer.writestring(buff, index, keytype)
				buff, index = NextIndex(buff, index + 1)

				index = DataTypes[keytype].Ser(buff, index) :: number

				buff = NextIndex(buff, index)

				--val
				local valtype = MetaUtils.Estimate(val)
				buffer.writestring(buff, index, valtype)

				buff, index = NextIndex(buff, index + 1)

				index = DataTypes[valtype].Ser(buff, index) :: number
				buff = NextIndex(buff, index)
			end

			return buff, index
		end,
		Des = function(buff: buffer, index: number)
			local amountofpairs = buffer.readu8(buff, index)
			index += 1

			local res = {}

			for i = 1, amountofpairs do
				local keytype = buffer.readstring(buff, index, 1)
				index += 1

				local key, j = DataTypes[keytype].Des(buff, index)
				index = j

				local valtype = buffer.readstring(buff, index, 1)
				index += 1

				local val, k = DataTypes[valtype].Des(buff, index)
				index = k

				res[key] = val
			end

			return res, index
		end,
	} :: SerDes<any>,

	--uint8
	C = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index)
			buffer.writeu8(buff, index, val)
			return buff, index + 1
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu8(buff, index), index + 1
		end,
	} :: SerDes<number>,

	--uint16
	D = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index + 2 - 1)
			buffer.writeu16(buff, index, val)
			return buff, index + 2
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu16(buff, index), index + 2
		end,
	} :: SerDes<number>,

	--uint32
	E = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index + 4 - 1)
			buffer.writeu32(buff, index, val)
			return buff, index + 4
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu32(buff, index), index + 4
		end,
	} :: SerDes<number>,

	--int8
	F = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index)
			buffer.writei8(buff, index, val)
			return buff, index + 1
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi8(buff, index), index + 1
		end,
	} :: SerDes<number>,

	--int16
	G = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index + 2 - 1)
			buffer.writei16(buff, index, val)
			return buff, index + 2
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi16(buff, index), index + 2
		end,
	} :: SerDes<number>,

	--int32
	H = {
		Ser = function(buff: buffer, index: number, val: number)
			buff = NextIndex(buff, index + 4 - 1)
			buffer.writei32(buff, index, val)
			return buff, index + 4
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi32(buff, index), index + 4
		end,
	} :: SerDes<number>,

	--bool
	K = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return buff, index --+ 1
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return true, index
		end,
	} :: SerDes<boolean>,

	L = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return buff, index --+ 1
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return false, index
		end,
	} :: SerDes<boolean>,
} :: { [string]: SerDes<any> }

return DataTypes
