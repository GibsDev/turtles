-- A program used to install miner program with dependancies
print("Removing old files")
fs.delete("/minerdeps")
fs.delete("miner")
fs.delete("update")

print("Downloading fresh code")
fs.makeDir("/minerdeps")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/arguments.lua", "arguments.lua")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/coords.lua", "coords.lua")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/miner.lua", "miner")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/utils.lua", "utils.lua")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/vector.lua", "vector.lua")
shell.run("wget", "https://raw.githubusercontent.com/GibsDev/mining-turtle/master/installer.lua", "update")

print("Moving deps into /minerdeps")
fs.move("/coords.lua", "/minerdeps/coords.lua")
fs.move("/utils.lua", "/minerdeps/utils.lua")
fs.move("/arguments.lua", "/minerdeps/arguments.lua")
