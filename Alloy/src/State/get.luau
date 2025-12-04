local main = script.Parent.Parent
local Types = require(main.Types)

return function(self: Types.State<unknown, unknown>)
	return self.__value
end
