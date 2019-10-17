enable_debug = true

function str_ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

function debug(info)
	if enable_debug then
		print(info)
	end
end

-- Checks if the given block data contains a name that is for an ore
function isOre(data)
	local index = data.name:find(":ore")
	if index ~= nil or str_ends_with(data.name, "ore") then return true end
	return false
end