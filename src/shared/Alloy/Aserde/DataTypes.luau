--!strict
--!native
--!optimize 2
local ATypes = require "./ATypes"
local MetaUtils = require "./MetaUtils"

type SerDes<T> = ATypes.SerDes<T>

local DataTypes = nil

local NextIndex = MetaUtils.NextIndex

DataTypes = table.freeze {

	--nil
	A = {
		Ser = function(buff: buffer, index: number, val: nil)
			return buff, index
		end,
		Des = function(buff: buffer, index: number)
			return nil, index
		end,
	} :: SerDes<nil>,

	--string
	B = {
		Ser = function(buff: buffer, index: number, val: string)
			--write u8 length

			buff, index = NextIndex(buff, index)

			buffer.writeu8(buff, index, #val)
			buff, index = NextIndex(buff, index + 1)

			--write string
			buff = NextIndex(buff, index + #val - 1)
			buffer.writestring(buff, index, val)
			return buff, index + #val
		end,
		Des = function(buff: buffer, index: number)
			local length = buffer.readu8(buff, index)
			index += 1

			return buffer.readstring(buff, index, length), index + length
		end,
	} :: SerDes<string>,

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

	--bool (true)
	K = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return buff, index
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return true, index
		end,
	} :: SerDes<boolean>,

	--bool (false)
	L = {
		Ser = function(buff: buffer, index: number, val: boolean)
			--buffer.writeu8(buff, index, val and 1 or 0)
			return buff, index
		end,
		Des = function(buff: buffer, index: number)
			--return buffer.readu8(buff, index) == 1, index --+ 1
			return false, index
		end,
	} :: SerDes<boolean>,

	--table
	M = {
		Ser = function(buff: buffer, index: number, val: {}, read: (buffer) -> {}, create: ({}) -> buffer)
			local arrbuff = create(val)
			local newbuff = MetaUtils.Merge(create { buffer.len(arrbuff) }, arrbuff)

			--print("length of created newbuff", buffer.len(newbuff), "arrbuff", buffer.len(arrbuff))

			buff = MetaUtils.Merge(buff, newbuff)

			return buff, index + buffer.len(newbuff)
		end,
		Des = function(buff: buffer, index: number, read: (buffer) -> {}, create: ({}) -> buffer)
			--byte 1: array length type
			local length: any = buffer.readstring(buff, index, 1)
			index += 1

			--byte 2: array length
			local l, i = DataTypes[length].Des(buff, index)
			length = l
			index = i

			local arrbuff = buffer.create(length)

			buffer.copy(arrbuff, 0, buff, index, length)
			--print("arrbuff", index, buffer.len(arrbuff), length)

			--bytes: buffer
			local arr = read(arrbuff)

			return arr, index + buffer.len(arrbuff)
		end,
	} :: SerDes<{}>,

	--color3
	N = {
		Ser = function(buff: buffer, index: number, val: Color3)
			buff = NextIndex(buff, index + 3 - 1)
			buffer.writeu8(buff, index, val.R * 255)
			buffer.writeu8(buff, index + 1, val.G * 255)
			buffer.writeu8(buff, index + 2, val.B * 255)
			return buff, index + 3
		end,
		Des = function(buff: buffer, index: number)
			local R = buffer.readu8(buff, index)
			local G = buffer.readu8(buff, index + 1)
			local B = buffer.readu8(buff, index + 2)

			return Color3.fromRGB(R, G, B), index + 3
		end,
	} :: SerDes<Color3>,

	--vector3
	O = {
		Ser = function(buff: buffer, index: number, val: Vector3)
			buff = NextIndex(buff, index + 3 - 1)
			buffer.writeu8(buff, index, val.X)
			buffer.writeu8(buff, index + 1, val.Y)
			buffer.writeu8(buff, index + 2, val.Z)
			return buff, index + 3
		end,
		Des = function(buff: buffer, index: number)
			local X = buffer.readu8(buff, index)
			local Y = buffer.readu8(buff, index + 1)
			local Z = buffer.readu8(buff, index + 2)

			return Vector3.new(X, Y, Z), index + 3
		end,
	} :: SerDes<Vector3>,

	--vector3int16
	P = {
		Ser = function(buff: buffer, index: number, val: Vector3int16)
			buff = NextIndex(buff, index + 6 - 1)
			buffer.writeu16(buff, index, val.X)
			buffer.writeu16(buff, index + 2, val.Y)
			buffer.writeu16(buff, index + 4, val.Z)
			return buff, index + 6
		end,
		Des = function(buff: buffer, index: number)
			local X = buffer.readu16(buff, index)
			local Y = buffer.readu16(buff, index + 2)
			local Z = buffer.readu16(buff, index + 4)

			return Vector3int16.new(X, Y, Z), index + 6
		end,
	} :: SerDes<Vector3int16>,

	--vector2
	Q = {
		Ser = function(buff: buffer, index: number, val: Vector2)
			buff = NextIndex(buff, index + 2 - 1)
			buffer.writeu8(buff, index, val.X)
			buffer.writeu8(buff, index + 1, val.Y)
			return buff, index + 2
		end,
		Des = function(buff: buffer, index: number)
			local X = buffer.readu8(buff, index)
			local Y = buffer.readu8(buff, index + 1)

			return Vector2.new(X, Y), index + 2
		end,
	} :: SerDes<Vector2>,

	--vector2int16
	R = {
		Ser = function(buff: buffer, index: number, val: Vector2int16)
			buff = NextIndex(buff, index + 4 - 1)
			buffer.writeu16(buff, index, val.X)
			buffer.writeu16(buff, index + 2, val.Y)
			return buff, index + 4
		end,
		Des = function(buff: buffer, index: number)
			local X = buffer.readu16(buff, index)
			local Y = buffer.readu16(buff, index + 2)

			return Vector2int16.new(X, Y), index + 4
		end,
	} :: SerDes<Vector2int16>,

	S = {
		Ser = function(buff: buffer, index: number, val: CFrame)
			buff = NextIndex(buff, index + 48 - 1)
			local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = val:GetComponents()

			buffer.writef32(buff, index, v0)
			buffer.writef32(buff, index + 4, v1)
			buffer.writef32(buff, index + 8, v2)
			buffer.writef32(buff, index + 12, v3)
			buffer.writef32(buff, index + 16, v4)
			buffer.writef32(buff, index + 20, v5)
			buffer.writef32(buff, index + 24, v6)
			buffer.writef32(buff, index + 28, v7)
			buffer.writef32(buff, index + 32, v8)
			buffer.writef32(buff, index + 36, v9)
			buffer.writef32(buff, index + 40, v10)
			buffer.writef32(buff, index + 44, v11)
			return buff, index + 48
		end,
		Des = function(buff: buffer, index: number)
			return CFrame.new(
				buffer.readf32(buff, index),
				buffer.readf32(buff, index + 4),
				buffer.readf32(buff, index + 8),
				buffer.readf32(buff, index + 12),
				buffer.readf32(buff, index + 16),
				buffer.readf32(buff, index + 20),
				buffer.readf32(buff, index + 24),
				buffer.readf32(buff, index + 28),
				buffer.readf32(buff, index + 32),
				buffer.readf32(buff, index + 36),
				buffer.readf32(buff, index + 40),
				buffer.readf32(buff, index + 44)
			),
				index + 48
		end,
	},

	--N
} :: { [string]: SerDes<any> }

return DataTypes
