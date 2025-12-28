--!strict

return table.freeze {
	_INCLUDE = {
		AllureRX = true,
		AllureBundle = true,
	},

	garbage_recursion_limit = 6,

	ASERDE_YIELD_READ = false,
	ASERDE_UNIQUE_READ_LIMIT = 500,
}
