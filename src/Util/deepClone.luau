--!nocheck
--!optimize 2
function deepClone(t: {})
	local result = {}

	for k, v in t do
		if typeof(v) == "table" and not v._updaters and not v.__value and not v.connections and not v.fn then
			result[k] = deepClone(v)
			continue
		end

		result[k] = v
	end

	return result
end

return deepClone
