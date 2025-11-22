--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"

type SerDes<T> = ATypes.SerDes<T>

return {

	--uint8
	C = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writeu8(buff, index, val)
			return index + 1
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu8(buff, index), index + 1
		end,
	} :: SerDes<number>,

	--uint16
	D = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writeu16(buff, index, val)
			return index + 2
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu16(buff, index), index + 2
		end,
	} :: SerDes<number>,

	--uint32
	E = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writeu32(buff, index, val)
			return index + 4
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readu32(buff, index), index + 4
		end,
	} :: SerDes<number>,

	--int8
	F = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writei8(buff, index, val)
			return index + 1
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi8(buff, index), index + 1
		end,
	} :: SerDes<number>,

	--int16
	G = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writei16(buff, index, val)
			return index + 2
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi16(buff, index), index + 2
		end,
	} :: SerDes<number>,

	--int32
	H = {
		Ser = function(buff: buffer, index: number, val: number)
			buffer.writei32(buff, index, val)
			return index + 4
		end,
		Des = function(buff: buffer, index: number)
			return buffer.readi32(buff, index), index + 4
		end,
	} :: SerDes<number>,

	--bool
	K = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return index --+ 1
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return true, index
		end,
	} :: SerDes<boolean>,

	L = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return index --+ 1
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return false, index
		end,
	} :: SerDes<boolean>,
} :: { [string]: SerDes<any> }
