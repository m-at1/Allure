--!nocheck
--!optimize 2
local Types = require "./Types"

function extend<T>(t0: Types.Allure, t: T)
	for k, t1 in t do
		if not t1 then
			continue
		end

		local t2 = require(script.Parent.Parent[t1])

		if typeof(t2) ~= "table" then
			t0[k] = t2
			continue
		end

		for k, v in t2 do
			t0[k] = v
		end
	end

	return t0
end

return extend
