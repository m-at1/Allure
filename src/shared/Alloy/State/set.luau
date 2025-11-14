local main = script.Parent.Parent
local Types = require(main.Types)

return function(self: Types.State<unknown, unknown>, val: any?)
	self.__value = val
	return val
end
