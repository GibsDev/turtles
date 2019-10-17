-- Basic utility functions
os.loadAPI("/minerdeps/utils.lua")
-- Track turtle location and expose other useful commands
os.loadAPI("/minerdeps/coords.lua")
-- Parse command line arguments
os.loadAPI("/minerdeps/arguments.lua")
-- So we can do some vector math for optimizations
os.loadAPI("/rom/apis/vector.lua")

-- Print debugging information
utils.enable_debug = true

-- Get command params
args = { ... }

-- TODO add a --help

-- Parse command line arguments
local pargs = arguments.parse(args)

-- Defaults to left
-- Right if "r" flag is present
local toRight = pargs["r"] or false
print("toRight: " .. tostring(toRight))

-- Length of tunnels to dig default 8
local length = pargs["l"] or 8
print("length: " .. tostring(length))

-- Amount of tunnels to dig
local width = pargs["w"] or 1
print("width: " .. tostring(width))

-- If the turtle should make room for a "player" or a "path"
local player_path = pargs["p"] or false
print("path for player: " .. tostring(player_path))

-- recursiveStrain helper function
function recursiveCheckForward()
	if turtle.detectOre() then
		turtle.digMove()
		recursiveStrain()
		if not turtle.back() then
			turtle.turnAround()
			turtle.digMove()
			turtle.turnAround()
		end
	end
end

-- Recursive strain mining function
function recursiveStrain()
	if turtle.detectOreUp() then -- UP
		turtle.digUpMove()
		recursiveStrain()
		turtle.digDownMove()
	end
	if turtle.detectOreDown() then -- DOWN
		turtle.digDownMove()
		recursiveStrain()
		turtle.digUpMove()
	end
	recursiveCheckForward() -- Front
	turtle.turnRight()
	recursiveCheckForward() -- Right
	turtle.turnRight()
	recursiveCheckForward() -- Back
	turtle.turnRight()
	recursiveCheckForward() -- Left
	turtle.turnRight()
end

-- Turtle mines a tunnel in a U shape to the right with a gap of 2 blocks
-- This is similar to how a player would strip mine

turtle.digUpMove()

function iteration()
	turtle.digMove() -- Move forward
	recursiveStrain() -- Look/mine ores
	if player_path then turtle.digDown() end
end

for i=1, length do
	iteration()
end

-- Move to the right and turn around leaving 2 block gap
if toRight then
	turtle.turnRight()
else
	turtle.turnLeft()
end
turtle.digMove()
recursiveStrain()
if player_path then turtle.digDown() end
turtle.digMove()
recursiveStrain()
if player_path then turtle.digDown() end
turtle.digMove()
recursiveStrain()
if player_path then turtle.digDown() end
if toRight then
	turtle.turnRight()
else
	turtle.turnLeft()
end

for i=1, length do
	iteration()
end

turtle.home()

-- TODO build a structure to store current ores in strain so we can optimize recursive mining
-- TODO inventory mangement/storage
-- TODO implement width calculations