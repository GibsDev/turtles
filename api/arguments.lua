-- Accepts the table from parsed from the command line
-- Parses arguments in the format -<flag>[<value>]
-- Flag is a single character
-- Value is any string or number
-- Numbers will attempt to be parsed and no value will be set to true
function parse(args)
	local a = {}
	for i = 1, table.getn(args) do
		if args[i]:sub(1, 1) == "-" then
			local flag = args[i]:sub(2, 2)
			if args[i]:len() == 2 then
				a[flag] = true
			elseif args[i]:len() > 2 then
				local value = args[i]:sub(3)
				if tonumber(value) ~= nil then
					value = tonumber(value)
				end
				a[flag] = value
			end
		end
	end
	return a
end

local function starts_with(str, start)
	return str:sub(1, #start) == start
 end