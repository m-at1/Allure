--!strict

return function(buff: buffer, length: number)
	print(length)
	local new = buffer.create(length)
	buffer.copy(new, 0, buff, 0, buffer.len(buff))
	return new
end
