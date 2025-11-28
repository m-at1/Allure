--!strict
--!optimize 2

local ALog = require "@self/ALog"
local ATypes = require "@self/ATypes"
local DataTypes = require "@self/DataTypes"
local ExpandBuffer = require "@self/ExpandBuffer"

local Metadata = require "@self/Metadata"
local Config = require "./Config"

-- THE GOAL:
--[[
    Effectively serialize in an optimized and quick way
    When shared amplifieds update, only serialize and send what's changed
]]

--[[
Data types {{
    - number
    - string
    - bool
    
    - Color3
    - Vector3
    - Vector3int16
}}

Metadata content {{
    format: int8

    [>0] = string   >0	

    [-11] = uint8    1
    [-12] = uint16   2
    [-13] = uint32   4

    [-21] = int8     1
    [-22] = int16    2
    [-23] = int32    4

    [-31] = f32      4
    [-32] = f64      8

    [-51] = Color3   (int8 int8 int8)    3
    [-52] = Vector3  (int8 int8 int8)    3
    [-53] = Vector3int16 (int16 int16 int16)     6

    [-100] = true    0   (metadata only)
    [-101] = false   0   (metadata only)
}}

New Metadata content {{
    format: string char

	A = array	 0	_
	B_ = string	 1	_

    C = uint8    0	1
    D = uint16   0	2
    E = uint32   0	4

    F = int8     0	1
    G = int16    0	2
    H = int32    0	4

    I = f32      0	4
    J = f64      0	8

    K = true    -1	1   (metadata only)
    L = false   -1	1   (metadata only)

	M = Color3 (int8 int8 int8)    		 0 3
    N = Vector3 (int8 int8 int8)  		 0 3
    O = Vector3int16 (int16 int16 int16) 0 6

	+_- = the next _uint8 are -any		2 _?	(shortcuts both metadata and data)

}}

]]

return {
	ReadBuffer = function(buff: buffer)
		if not buff then
			ALog.logError("noValues", "Aserde.ReadBuffer")
		end
		local len = buffer.len(buff)
		if len < 1 then
			ALog.logError("emptyBuffer", "Aserde.ReadBuffer")
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

			warn "reading"

			if buffer.readstring(buff, index, 1) == "+" then
				--next byte: type of amount
				index += 1
				local amountbyte, i = Metadata.Read(buff, index)
				local a, j = amountbyte.Des(buff, i)
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
				warn(amount)
				if Config.ASERDE_YIELD_READ then
					task.wait()
				end
				local decoded, j = metabyte.Des(buff, index)
				index = j
				table.insert(res, decoded)
			end

			if index >= buffer.len(buff) then
				break
			end
		end

		--[[print(metadata)

		for _, a in metadata do
			local val, j = a[1].Des(buff, index, a[3])

			--warn(val)
			for i = 1, amounts[index] do
				table.insert(res, val)
			end
			index = j

			task.wait()
		end]]

		return #res > 1 and res or res[1]
	end,
	CreateBuffer = function(values: {})
		--CREATE METADATA

		--local metadatalength = 0
		--local totalbufferlength = 0

		--
		local amounts = {} :: { [any]: { any } } --typeof(val) = {{vals}, amount}

		for _, val in values do
			--[[if not amounts[val] then
				--totalbufferlength += Metadata.EstimateLength(val)
				if typeof(val) == "string" then
					metadatalength += 1
				end
			end]]

			local datat = Metadata.Estimate(val)

			amounts[datat] = amounts[datat] or { 0, {} }
			amounts[datat][1] += 1
			table.insert(amounts[datat][2], val)
		end

		local data = buffer.create(1)
		local index = 0

		print(amounts)

		for datat, am in amounts do
			if am[1] > 1 then
				print "yes"
				data = ExpandBuffer(data, index)
				buffer.writestring(data, index, "+")
				index += 1

				--write amount type and amount
				local c, i = Metadata.Write(data, index, am[1])
				data, index = c.Ser(data, i, am[1])

				local b, j = Metadata.Write(data, index, am[2][1])
				index = j

				for k = 1, am[1] do
					data, index = b.Ser(data, index, am[2][k])
				end
			else
				local a, j, c = Metadata.Write(data, index, am[2][1])
				warn(a, j, c)
				data = c
				print(j)
				data, index = a.Ser(data, j, am[2][1])
				print(index)
			end
			warn(index)
			--warn(index)
			--local a, i = Metadata.Write(data, index, val)
			--index = a.Ser(data, index, val)
		end

		print(buffer.len(data))

		--warn(amounts)

		--local sers = {}
		--local index = 0

		--[[for datat, am in amounts do
			local ser_bytes = datat == "B"
					and (function()
						local a = #am[2]

						for _, st in am[2] do
							a += #st
						end

						return a
					end)()
				or Metadata.EstimateLengthDataType(datat) * am[1]
			warn(ser_bytes)
			totalbufferlength += 1 + ser_bytes + (am[1] > 1 and 2 + Metadata.EstimateLength(am[1]) or 0)
			-- true true true true true --> +C5K
			-- true false false true true --> KLLKK

			-- metabyte + ser_bytes + (amount ? metabyte+number_ser_bytes : 0)
		end

		warn(totalbufferlength)]]

		--local metabuffer = buffer.create(metadatalength)

		--[[local amounts2 = table.clone(amounts)
		for j, val in values do
			local datat = Metadata.Estimate(val)

			if amounts2[datat] > 1 then
				buffer.writestring(metabuffer, index, "+")
				local amounttype = Metadata.Estimate(amounts2[datat])
				warn("Type:", amounttype)
				index += 1

				-- type of the amount
				buffer.writestring(metabuffer, index, amounttype)
				index += 1

				-- the amount
				index = DataTypes[Metadata.Estimate(amounts2[datat])].Ser(metabuffer, index)
			end

			-- the value
			local ser, i = Metadata.Write(metabuffer, index, val)
			sers[j] = ser

			amounts2[datat] = nil

			index = i
		end]]

		--[[ FILL DATA

		local data = buffer.create(totalbufferlength)
		local index = 0

		--print(totalbufferlength)

		warn(amounts)

		for datat, am in amounts do
			--for _, val in values do
			if am[1] > 1 then
				--local datat = Metadata.Estimate(val)
				--local a

				--if amounts[datat] and amounts[datat][1] > 1 then -- if its the first value in a row of this type
				--local am = amounts[datat]
				buffer.writestring(data, index, "+")
				index += 1

				--write amount type and amount
				local c, i = Metadata.Write(data, index, am[1])
				index = c.Ser(data, i, am[1])

				local b, j = Metadata.Write(data, index, am[2][1])
				index = j

				for k = 1, am[1] do
					index = b.Ser(data, index, am[2][k])
				end
			else
				local a, j = Metadata.Write(data, index, am[2][1])
				index = a.Ser(data, j, am[2][1])
			end
			--warn(index)
			--local a, i = Metadata.Write(data, index, val)
			--index = a.Ser(data, index, val)
		end

		--[[ merge results
		local result = buffer.create(metadatalength + totalbufferlength + 1)

		buffer.writeu8(result, 0, metadatalength)
		buffer.copy(result, 1, metabuffer)
		buffer.copy(result, 1 + metadatalength, data)]]

		return data
	end,
}
