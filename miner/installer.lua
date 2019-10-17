-- A program used to install miner program with dependancies
local program = "/gibsdev/miner/miner.lua"
local updater = "/gibsdev/miner/installer.lua"
local files = {}
files[program] = "https://raw.githubusercontent.com/GibsDev/turtles/master/miner/miner.lua"
files[updater] = "https://raw.githubusercontent.com/GibsDev/turtles/master/miner/installer.lua"
files["/gibsdev/api/arguments.lua"] = "https://raw.githubusercontent.com/GibsDev/turtles/master/api/arguments.lua"
files["/gibsdev/api/coords.lua"] = "https://raw.githubusercontent.com/GibsDev/turtles/master/api/coords.lua"
files["/gibsdev/api/utils.lua"] = "https://raw.githubusercontent.com/GibsDev/turtles/master/api/utils.lua"

local program_alias = "miner.lua"
local update_alias = "update-miner.lua"

print("Removing old files...")
-- Remove src files
for file, url in files do
	if fs.exists(file) then
		fs.delete(file)
	end
end
-- Remove shortcuts created by alias
if fs.exists(program_alias)
	fs.delete(program_alias)
end
if fs.exists(update_alias)
	fs.delete(update_alias)
end

print("Creating directories...")
local root_folder = "/gibsdev"
local api_folder = root_folder .. "/api"
local miner_folder = root_folder .. "/miner"

if not fs.exists(root_folder) then
	fs.makedir(root_folder)
end
if not fs.exists(api_folder) then
	fs.makedir(api_folder)
end
if not fs.exists(miner_folder) then
	fs.makedir(miner_folder)
end
print("Downloading files...")
for file, url in files do
	shell.run("wget", url, file)
end

shell.run("alias", program_alias, program)
shell.run("alias", update_alias, updater)
