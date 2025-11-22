--!strict
--!optimize 2
local EncodingService = game:GetService "EncodingService"

local ALog = require "@self/ALog"
local DataTypes = require "@self/DataTypes"
local Metadata = require "@self/Metadata"

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

		warn(len)

		--warn(len)

		--READ METADATA
		--local firstbyte = buffer.readu8(buff, index) --amount of metadata <- not length because of string metadata
		--index += 1

		--warn(firstbyte)

		--local metadata = {} :: { [any]: { any } }

		local limit = 0
		while limit < 500 do
			task.wait()
			limit += 1
			local amount = 1

			if buffer.readstring(buff, index, 1) == "+" then
				--next byte: type of amount
				index += 1
				local amountbyte, i = Metadata.Read(buff, index)
				amount, index = amountbyte.Des(buff, i + 1)
				-- next byte: the value type thats being repeated
			end
			--TODO: instead of val, use the data type
			--as in the next 2 values are uint8, read 3 uint8 after
			--the next 3 values are K
			local metabyte, i = Metadata.Read(buff, index)
			index = i

			for i = 1, amount do
				task.wait()
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
		local totalbufferlength = 0

		--
		local amounts = {} :: { [any]: { any } } --typeof(val) = {val, amount}

		for _, val in values do
			--[[if not amounts[val] then
				--totalbufferlength += Metadata.EstimateLength(val)
				if typeof(val) == "string" then
					metadatalength += 1
				end
			end]]

			local datat = Metadata.Estimate(val)

			amounts[datat] = amounts[datat] or { 0, val }
			amounts[datat][1] += 1
		end

		warn(amounts)

		--local sers = {}
		--local index = 0

		for datat, am in amounts do
			totalbufferlength += 1 + Metadata.EstimateLengthDataType(datat) + (am[1] > 1 and 2 + Metadata.EstimateLength(
				am[1]
			) or 0)
			-- true true true true true --> +C5K
			-- true false false true true --> KLLKK

			-- metabyte + (amount ? metabyte+number_ser_bytes : 0) + ser_bytes
		end

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

		-- FILL DATA

		local data = buffer.create(totalbufferlength)
		local index = 0

		print(totalbufferlength)

		for datat, am in amounts do
			if am[1] > 1 then
				buffer.writestring(data, index, "+")
				index += 1

				--write amount type and amount
				index = Metadata.Write(data, index, am[1]).Ser(data, index + 1, am[1])
			end
			warn(index)
			index = Metadata.Write(data, index, am[2]).Ser(data, index + 1, am[2])
		end

		--[[ merge results
		local result = buffer.create(metadatalength + totalbufferlength + 1)

		buffer.writeu8(result, 0, metadatalength)
		buffer.copy(result, 1, metabuffer)
		buffer.copy(result, 1 + metadatalength, data)]]

		return data
	end,
}
