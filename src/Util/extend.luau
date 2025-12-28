--!nocheck
--!optimize 2
local Types = require "./Types"

function extend<T>(t0: Types.Allure, t: T)
	for t1, _ in t do
		if not t1 then
			continue
		end

		t1 = require(script.Parent.Parent[t1])

		for v, k in t1 do
			t0[v] = k
		end
	end

	return t0
end

return extend
