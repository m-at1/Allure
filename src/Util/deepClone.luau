--!nocheck
--!optimize 2
function deepClone(t: {})
	local result = {}

	for k, v in t do
		if typeof(v) == "table" then
			result[k] = deepClone(v)
			continue
		end

		result[k] = v
	end

	return result
end

return deepClone
