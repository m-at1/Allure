--!strict
--!optimize 2
function deepMerge(...)
	local result = {}
	for _, t in ipairs({ ... }) do
		for k, v in pairs(t) do
			if type(v) == "table" and type(result[k]) == "table" then
				result[k] = deepMerge(result[k], v)
			else
				result[k] = v
			end
		end
	end
	return result
end

return deepMerge
