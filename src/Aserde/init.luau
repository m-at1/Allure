--!strict
--!optimize 2

local ALog = require "@self/ALog"
local ATypes = require "@self/ATypes"
local MetaUtils = require "@self/MetaUtils"

local Metadata = require "@self/Metadata"
local Config = require "./Config"

--[[

Metadata and types

	A = nil	(metabyte only)
    B = string

    C = uint8
    D = uint16
    E = uint32

    F = int8
    G = int16
    H = int32

    I = f32
    J = f64

	K = true    (metabyte only)
    L = false   (metabyte only)

	M = dict/array table

    N = Color3
    O = Vector3
    P = Vector3int16

	Q = Vector2
	R = Vector2int16

	S = CFrame (Lossless)

]]
local Aserde = {} :: ATypes.Aserde

Aserde = table.freeze {
	SpecialType = MetaUtils.SpecialType,
	ReadBuffer = function(buff: buffer)
		if not buff then
			ALog.logError("noValues", "Aserde.ReadBuffer")
		end
		local len = buffer.len(buff)
		if len < 1 then
			return {}
			--ALog.logError("emptyBuffer", "Aserde.ReadBuffer")
		end

		local res = {}
		local index = 0

		--warn(len)

		--warn(len)

		--READ METADATA
		--local firstbyte = buffer.readu8(buff, index) --amount of metadata <- not length because of string metadata
		--index += 1

		--warn(firstbyte)

		--local metadata = {} :: { [any]: { any } }

		local limit = 0
		while limit < Config.ASERDE_UNIQUE_READ_LIMIT do
			task.wait()
			limit += 1
			local amount = 1

			if index >= buffer.len(buff) then
				break
			end

			--warn "reading"

			if buffer.readstring(buff, index, 1) == "+" then
				--next byte: type of amount
				index += 1
				local amountbyte, i = Metadata.Read(buff, index)

				local a, j = amountbyte.Des(buff, i, Aserde.ReadBuffer, Aserde.CreateBuffer)
				amount = a
				index = j
				-- next byte: the value type thats being repeated
			end

			local metabyte, i = Metadata.Read(buff, index)
			index = i

			if not metabyte then
				warn("nil metabyte on index", i - 1, "buffer len", buffer.len(buff))
			end

			for i = 1, amount do
				--warn(amount)
				if Config.ASERDE_YIELD_READ then
					task.wait()
				end

				local key = nil

				if index < buffer.len(buff) - 1 and buffer.readstring(buff, index, 1) == "\\" then
					--1: type of key
					index += 1
					local amountbyte, m = Metadata.Read(buff, index)

					--2: key
					local a, j = amountbyte.Des(buff, m, Aserde.ReadBuffer, Aserde.CreateBuffer)
					key = a
					index = j
					-- next byte: the value type thats being repeated
				end

				local decoded, j = metabyte.Des(buff, index, Aserde.ReadBuffer, Aserde.CreateBuffer)
				index = j

				if key then
					res[key] = decoded
				else
					table.insert(res :: { any }, decoded)
				end
			end

			if index >= buffer.len(buff) then
				break
			end
		end

		return res
	end,
	CreateBuffer = function(values: { [any]: any })
		--CREATE METADATA

		--local metadatalength = 0
		--local totalbufferlength = 0

		--
		local amounts = {} :: { [any]: { any } | { number | {} } } --typeof(val) = {{vals}, amount}

		for k, val in values do
			local datat = Metadata.Estimate(val)

			amounts[datat] = amounts[datat] or { 0, {} }
			amounts[datat][1] += 1
			if k then
				amounts[datat][2][k] = val
			else
				table.insert(amounts[datat][2] :: { any }, val)
			end
		end

		local data = buffer.create(1)
		local index: number = 0

		--print(amounts)

		for datat, am in amounts do
			if am[1] > 3 then
				data = MetaUtils.NextIndex(data, index)
				buffer.writestring(data, index, "+")
				index += 1

				--[[write amount type and amount
				local c, i, r = Metadata.Write(data, index, am[1])
				data = r
				data, index = c.Ser(data, i, am[1])

				local b, j, m = Metadata.Write(data, index, am[2][1])
				data = m
				index = j]]

				local b = nil :: any

				for k, v in am[2] do
					--write amount type and amount
					local c, i, r = Metadata.Write(data, index, am[1])
					data = r
					data, index = c.Ser(data, i, am[1], Aserde.ReadBuffer, Aserde.CreateBuffer)

					b, index, data = Metadata.Write(data, index, v)

					break
				end

				--[[for k = 1, am[1] do
					data, index = b.Ser(data, index, am[2][k])
				end]]
				for k, v in am[2] do
					--code the key
					if typeof(k) ~= "number" then
						--1: \
						data = MetaUtils.NextIndex(data, index)
						buffer.writestring(data, index, "\\")
						index += 1
						--2: key type
						local serde, newi, newdata = Metadata.Write(data, index, k)
						--3: key
						k = MetaUtils.handleSpecialType(k)
						data, index = serde.Ser(newdata, newi, k, Aserde.ReadBuffer, Aserde.CreateBuffer)
					end
					v = MetaUtils.handleSpecialType(v)
					data, index = b.Ser(data, index, v, Aserde.ReadBuffer, Aserde.CreateBuffer)
				end
			else
				for k, v in am[2] do
					local a, j, c = Metadata.Write(data, index, v)

					data = c
					index = j

					--code the key

					if typeof(k) ~= "number" then
						--1: \
						data = MetaUtils.NextIndex(data, index)
						buffer.writestring(data, index, "\\")
						index += 1
						--2: key type
						local serde, newi, newdata = Metadata.Write(data, index, k)
						--3: key
						k = MetaUtils.handleSpecialType(k)
						data, index = serde.Ser(newdata, newi, k, Aserde.ReadBuffer, Aserde.CreateBuffer)
					end

					v = MetaUtils.handleSpecialType(v)
					data, index = a.Ser(data, index, v, Aserde.ReadBuffer, Aserde.CreateBuffer)

					--break
				end
			end
			--warn(index)
			--local a, i = Metadata.Write(data, index, val)
			--index = a.Ser(data, index, val)
		end

		--print(buffer.len(data))

		return data
	end,
} :: ATypes.Aserde

return Aserde
