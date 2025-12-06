--!strict

local prefix =
	"[Aserde]\n\t\t>> This is the Alloy's initial serializer.\n\t\t>> Encountered an error that could not be resolved:\n\t\t\t"

local errors = {
	noValues = "%s received zero arguments.",
	emptyBuffer = "%s received an empty buffer.",
}

return {
	logError = function(errorid: string, ...: string)
		--local stack = debug.traceback("\n\\\\\\--------- \tStack Traceback\t ---------///", 2)
		error(prefix .. string.format(errors[errorid] :: any, ...) .. "\n\t\t\tError id: " .. errorid, 0)
	end,

	logWarning = function(errorid: string, ...: string)
		local stack =
			debug.traceback("\n\n\\\\\\\t---------\t--------- \t\t\tStack Traceback\t\t\t ---------\t---------\t///", 2)
		warn(
			prefix
				.. string.format(errors[errorid] :: any, ...)
				.. "\n\t\t\tError id: "
				.. errorid
				.. if stack then stack else ""
		)
	end,
}
