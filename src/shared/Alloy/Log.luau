--!strict

local prefix = "[Alloy]\n\t\t\t"

local errors = {
	expected = "Expected %s, got %s",
	noGarbage = "Given %s, expected a garbage collector",
	garbageRecursion = "Garbage cleanup recursion reached: cleanup halted",
	amplifiedTable = "The value passed to ...:Amplified() is not a table",
	amplifiedDoubleConnection = 'Attempt to connect an amplified table\'s property "%s" twice',
	onEventNone = 'Event "%s" passed to Alloy.onEvent does not exist for the object %s',
	onChangeNone = 'Property "%s" passed to Alloy.onChange does not exist for the object %s',
}

return {
	logError = function(errorid: string, ...: string)
		--local stack = debug.traceback("\n\\\\\\--------- \tStack Traceback\t ---------///", 2)
		error(prefix .. string.format(errors[errorid], ...) .. "\n\t\t\tError id: " .. errorid, 0)
	end,

	logWarning = function(errorid: string, ...: string)
		local stack =
			debug.traceback("\n\n\\\\\\\t---------\t--------- \t\t\tStack Traceback\t\t\t ---------\t---------\t///", 2)
		warn(
			prefix
				.. string.format(errors[errorid], ...)
				.. "\n\t\t\tError id: "
				.. errorid
				.. if stack then stack else ""
		)
	end,
}
