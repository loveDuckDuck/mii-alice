function UUID()
	local fn = function(x)
		local r = math.random(16) - 1
		r = (x == "x") and (r + 1) or (r % 4) + 9
		return ("0123456789abcdef"):sub(r, r)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function FileExists(url)
	-- Get info once and return an explicit boolean
	local info = love.filesystem.getInfo(url)
	return info ~= nil and info.type == "file"
end