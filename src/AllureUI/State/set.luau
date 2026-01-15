local Types = require(script.Parent.Parent.Parent.Util.Types)

return function(self: Types.State<unknown, unknown>, val: any?)
	self.__value = val
	return val
end
