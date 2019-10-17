--[[
 An API that overrides the original turtle functions to keep
 track of the turtle location as it moves
 --]]

 -- Adds vector API
os.loadAPI("/rom/apis/vector.lua")
os.loadAPI("/minerdeps/utils.lua")

-- The amount of blocks that will be mined before the turtle stops trying
local GRAVITY_BLOCK_LIMIT = 64
local OBSTRUCTION_WAIT_TIME = 60

-- Copy table from turtle to inherit functionality
_turtle = {}

-- Sides of turtle
SIDE = {
	FRONT = vector.new(0,1,0),
	BACK = vector.new(0,-1,0),
	LEFT = vector.new(-1,0,0),
	RIGHT = vector.new(1,0,0),
	UP = vector.new(0,0,1),
	DOWN = vector.new(0,0,-1)
}

-- Directions on plane the turtle rotates on (XY for this api)
DIR = {
	NORTH = SIDE.FRONT,
	EAST = SIDE.RIGHT,
	SOUTH = SIDE.BACK,
	WEST = SIDE.LEFT
}

HOME = vector.new(0,0,0)

-- Current direction the bot is facing
local facing = DIR.NORTH
-- Current coordinates of bot
local location = vector.new(0,0,0)

-- Search and consume up to a whole stack of fuel
turtle.refuelAny = function()
	utils.debug("refueling")
	for i = 1, 16 do
		turtle.select(i)
		if turtle.refuel(64) then
			return true
		end
	end
	return false
end

_turtle.turnRight = turtle.turnRight
-- Track the turtle turning right
turtle.turnRight = function()
	_turtle.turnRight()
	if facing == DIR.NORTH then
		facing = DIR.EAST
	elseif facing == DIR.EAST then
		facing = DIR.SOUTH
	elseif facing == DIR.SOUTH then
		facing = DIR.WEST
	elseif facing == DIR.WEST then
		facing = DIR.NORTH
	end
	return true
end

_turtle.turnLeft = turtle.turnLeft
-- Track the turtle turning left
turtle.turnLeft = function()
	_turtle.turnLeft()
	if facing == DIR.NORTH then
		facing = DIR.WEST
	elseif facing == DIR.EAST then
		facing = DIR.NORTH
	elseif facing == DIR.SOUTH then
		facing = DIR.EAST
	elseif facing == DIR.WEST then
		facing = DIR.SOUTH
	end
	return true
end

_turtle.forward = turtle.forward
-- track the turtle moving forward
turtle.forward = function()
	if turtle.getFuelLevel() == 0 then
		turtle.refuelAny()
	end
	if _turtle.forward() then
		location = location:add(facing)
		return true
	end
	return false
end

_turtle.back = turtle.back
-- Track the turtle moving back
turtle.back = function()
	if turtle.getFuelLevel() == 0 then
		turtle.refuelAny()
	end
	if _turtle.back() then
		location = location:sub(facing)
		return true
	end
	return false
end

_turtle.up = turtle.up
-- Track the turtle moving up
turtle.up = function()
	if turtle.getFuelLevel() == 0 then
		turtle.refuelAny()
	end
	if _turtle.up() then
		location = location:add(SIDE.UP)
		return true
	end
	return false
end

_turtle.down = turtle.down
-- Track the turtle moving down
turtle.down = function()
	if turtle.getFuelLevel() == 0 then
		turtle.refuelAny()
	end
	if _turtle.down() then
		location = location:add(SIDE.DOWN)
		return true
	end
	return false
end

--[[
Custom functions
--]]

-- Turn the turtle around 180
turtle.turnAround = function()
	turtle.turnRight()
	turtle.turnRight()
end

-- Check for ore in front
turtle.detectOre = function()
	local success, data = turtle.inspect()
	return success and utils.isOre(data)
end

-- Check for ore up
turtle.detectOreUp = function()
	local success, data = turtle.inspectUp()
	return success and utils.isOre(data)
end

-- Check for ore down
turtle.detectOreDown = function()
	local success, data = turtle.inspectDown()
	return success and utils.isOre(data)
end

-- Perform a dig and move forward
-- Attempts to account for obstructions
turtle.digMove = function()
	for i = 0, GRAVITY_BLOCK_LIMIT do
		if not turtle.dig() then
			break
		end
		if i == GRAVITY_BLOCK_LIMIT then
			error("Tried to dig more than " .. GRAVITY_BLOCK_LIMIT .. " for one move")
		end
	end
	for i = 0, OBSTRUCTION_WAIT_TIME do
		if turtle.forward() then
			return true
		end
		os.sleep(1)
	end
	error("Tried to wait more than " .. OBSTRUCTION_WAIT_TIME .. " for one move")
	return false
end

-- Perform a dig and move up
-- Attempts to account for obstructions
turtle.digUpMove = function()
	for i = 0, GRAVITY_BLOCK_LIMIT do
		if not turtle.digUp() then
			break
		end
		if i == GRAVITY_BLOCK_LIMIT then
			error("Tried to dig more than " .. GRAVITY_BLOCK_LIMIT .. " for one move")
		end
	end
	for i = 0, OBSTRUCTION_WAIT_TIME do
		if turtle.up() then
			return true
		end
		os.sleep(1)
	end
	error("Tried to wait more than " .. OBSTRUCTION_WAIT_TIME .. " for one move")
	return false
end

-- Perform a dig and move down
-- Attempts to account for obstructions
turtle.digDownMove = function()
	-- Dont need to check for gavity blocks
	turtle.digDown()
	for i = 0, OBSTRUCTION_WAIT_TIME do
		if turtle.down() then
			return true
		end
		os.sleep(1)
	end
	error("Tried to wait more than " .. OBSTRUCTION_WAIT_TIME .. " for one move")
	return false
end

-- Face the given direction
turtle.face = function(dir)
	if facing == dir then
		return 0
	end
	if facing == DIR.NORTH and dir == DIR.WEST then
		turtle.turnLeft()
		return 1
	elseif facing == DIR.WEST and dir == DIR.SOUTH then
		turtle.turnLeft()
		return 1
	elseif facing == DIR.SOUTH and dir == DIR.EAST then
		turtle.turnLeft()
		return 1
	elseif facing == DIR.EAST and dir == DIR.NORTH then
		turtle.turnLeft()
		return 1
	else
		local turns = 0
		while facing ~= dir do
			turtle.turnRight()
			turns = turns + 1
		end
		return turns
	end
end

-- Return to where the script started
turtle.home = function()
	turtle.moveTo(HOME, DIR.NORTH)
end

-- Move to a given position and face a given direction
turtle.moveTo = function(dest, dir)
	local x_dist = dest.x - location.x
	local limit = math.abs(x_dist)
	while x_dist ~= 0 and limit > 0 do
		if x_dist < 0 then
			turtle.face(DIR.WEST)
		else
			turtle.face(DIR.EAST)
		end
		turtle.digMove()
		x_dist = dest.x - location.x
		limit = limit - 1
	end
	local y_dist = dest.y - location.y
	limit = math.abs(y_dist)
	while y_dist ~= 0 do
		if y_dist < 0 then
			turtle.face(DIR.SOUTH)
		else
			turtle.face(DIR.NORTH)
		end
		turtle.digMove()
		y_dist = dest.y - location.y
		limit = limit - 1
	end
	local zdist = dest.z - location.z
	limit = math.abs(zdist)
	while zdist ~= 0 and limit > 0 do
		if zdist < 0 then
			turtle.digDownMove()
		else
			turtle.digUpMove()
		end
		zdist = dest.z - location.z
		limit = limit - 1
	end
	turtle.face(dir)
end