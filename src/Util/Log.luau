--!strict

local prefix = "[%s]\n\t\t\t"

local errors = {
	expected = "Expected %s, got %s",
	noGarbage = "Given %s, expected a garbage collector",
	garbageRecursion = "Garbage cleanup recursion reached: cleanup halted",
	amplifiedTable = "The value passed to ...:Amplified() is not a table",
	amplifiedDoubleConnection = 'Attempt to connect an amplified table\'s property "%s" twice',
	onEventNone = 'Event "%s" passed to Allure.onEvent does not exist for the object %s',
	onChangeNone = 'Property "%s" passed to Allure.onChange does not exist for the object %s',

	clientsideSharedMod = "Attempt to modify shared amplified on the client.",
	strangeSharedMod = "Bulk modification of shared amplified received non-table value.",
}

return {
	logError = function(origin, errorid: string, ...: string)
		--local stack = debug.traceback("\n\\\\\\--------- \tStack Traceback\t ---------///", 2)
		error(
			string.format(prefix :: any, origin)
				.. string.format(errors[errorid] :: any, ...)
				.. "\n\t\t\tError id: "
				.. errorid,
			0
		)
	end,

	logWarning = function(origin, errorid: string, ...: string)
		local stack =
			debug.traceback("\n\n\\\\\\\t---------\t--------- \t\t\tStack Traceback\t\t\t ---------\t---------\t///", 2)
		warn(
			string.format(prefix :: any, origin)
				.. string.format(errors[errorid] :: any, ...)
				.. "\n\t\t\tError id: "
				.. errorid
				.. if stack then stack else ""
		)
	end,
}
