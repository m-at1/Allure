--!strict

-- Replicated buff2 as the ending of buff1
return function(buff1: buffer, buff2: buffer)
	local len1 = buffer.len(buff1)
	local len2 = buffer.len(buff2)

	local new = buffer.create(len1 + len2)
	buffer.copy(new, 0, buff1, 0, len1)
	buffer.copy(new, len1, buff2, 0, len2)
	return new
end
