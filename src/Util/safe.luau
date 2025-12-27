--!nocheck
--!optimize 2

function safe(req: ModuleScript?)
	if req then
		return require(req)
	end
	return nil
end

return safe
