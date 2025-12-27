local Types = require(script.Parent.Parent.Parent.Util.Types)

return function(self: Types.State<unknown, unknown>)
	return self.__value
end
