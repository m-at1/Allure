--!strict

return table.freeze {
	_INCLUDE = {
		AlloyRX = true,
		--AlloyBundle = true,
	},

	garbage_recursion_limit = 6,

	ASERDE_YIELD_READ = false,
	ASERDE_UNIQUE_READ_LIMIT = 500,
}
