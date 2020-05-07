-- This Version

-- 06/05/2020
-- DrJoachim
local version = '0.06'

-- ToDoList
-- Refactor code
-- Make sure turtle returns to start 
-- Make turtle eddrop stuff in the main branch, not in side branches
-- Make turtle close off the branches
-- Add Code to place torch each time it starts
-- Add Fuel Code so can know almost how much fuel you need
-- Add second fuel slot if you go allout diggin
-- Mabye add code that make turtle make new line of tunnels

--Local
local curX = -1  -- you start before the main hall 
local curZ = 0
local curY = 0 

local debug = false

local branchDepth = 0 -- How deep Did User Pick
local branchNumber = 0 -- How many branches does the user want?

local maxX = 3*branchNumber
local maxZ = branchDepth+1

local torchCount = 0 -- Tracks the number of torches
local torchLocations = {}

local chestCount = 0 -- Tracks the number of chests
local chestLocations = {}

local fuelCount = 0 -- Tracks the number of fuelItems
local fuelLocations = {}

local MD = 3 -- How Many Blocks Apart From Each Mine

local emptyLocation = -1

local onlight = 0 -- When to Place Torch
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error
local Way = 0 -- 0 = Left and 1 = Right


local trash = {
	["minecraft:cobblestone"] = true,
	["minecraft:dirt"] = true,
	["minecraft:gravel"] = true,
	["minecraft:andesite"]=true,
	["minecraft:diorite"]=true,
	["minecraft:granite"]=true
  }


local function initializeLocations()
	for i=1,16 do	
		turtle.select(i)
		local details = turtle.getItemDetail(i);
		if details ~= nil then
			if string.find(details.name,"torch") then						
				torchCount = torchCount + turtle.getItemCount(i)
				table.insert(torchLocations,i)
			elseif string.find(details.name,"chest") then			
				chestCount = chestCount + turtle.getItemCount(i)
				table.insert(chestLocations,i)
			elseif turtle.refuel(0) then
				fuelCount = fuelCount + turtle.getItemCount(i)
				table.insert(fuelLocations,i)
			end
		end
	end
	turtle.select(1)
	logger.log("**Locations**")
	logger.log("Found "..torchCount.." torches on these locations: "..table.concat(torchLocations,", "))
	logger.log("Found "..chestCount.." chests on these locations: "..table.concat(chestLocations,", "))
	logger.log("Found "..fuelCount.." fuel items on these locations: "..table.concat(fuelLocations,", "))
	logger.log("*************")
end

--Checking
local function checkFuel()
	local branchSteps = branchDepth * 2 * branchNumber
	local mainSteps = 9 * branchNumber
	local totalSteps = branchSteps + mainSteps
	logger.log("totalsteps = "..totalSteps)
	if turtle.getFuelLevel() == "unlimited" then 
		logger.log("No need for fuel")
		
	elseif  turtle.getFuelLevel() >= totalSteps then
		logger.log("fuel level is now "..turtle.getFuelLevel())
		logger.log("There should be enough fuel to mine the whole branch")
	elseif turtle.getFuelLevel() < totalSteps then
		logger.log("No fuel enough, refueling")
		local x = 1
		while turtle.getFuelLevel() < totalSteps or x<=#fuelLocations do
			local v = fuelLocations[x]
			logger.log("refueling with location "..x)
			turtle.select(v)
			turtle.refuel(turtle.getItemCount(v))
			x = x + 1
			logger.log("fuel level is now "..turtle.getFuelLevel())
		end
	end

end



local function getNextChest()
	local chestLocId = 0
	local i = 1
	while chestLocId == 0 and i <= #chestLocations do
		if turtle.getItemCount(chestLocations[i]) > 0 then
			chestLocId = chestLocations[i]
		end
		i = i+1
	end
	logger.log("Chestlocation found at "..chestLocId)
	return chestLocId
end

local function getNextTorch()
	local torchLocId = 0
	local i = 1
	while torchLocId == 0 and i <= #torchLocations do
		if turtle.getItemCount(torchLocations[i]) > 0 then
			torchLocId = torchLocations[i]
		end
		i = i+1
	end
	logger.log("Torchlocation found at "..torchLocId)
	return torchLocId
end


local function placeChestDown()
	local tempY = curY
	while curY > -1 do
		turtle.digDown()
		turtle.down()
		curY = curY -1
	end
	
	turtle.digDown()
	turtle.select(getNextChest())
	turtle.placeDown()
	chestCount = chestCount - 1
	if chestCount == 0 then
		logger.log("Turtle ran out of chests")
	else
		logger.log("Chest placed, turtle has "..chestCount.." chests left.")
	end

	for i=1,16 do
		if turtle.getItemCount(i)>0 then
			turtle.select(i)
			if not (string.find(turtle.getItemDetail(i).name,"chest") or string.find(turtle.getItemDetail(i).name,"torch") or turtle.refuel(0)) then 
				turtle.dropDown()
			end
		end
	end

	turtle.select(1)
	while curY < tempY do
		turtle.up()
		curY = curY + 1
	end
end

function initializeLogger()
	--pastebin get J2bF3fpf logger
	os.loadAPI("logger")
end

local function getNextEmptyLocation()
	for i= 1,16 do 
		if turtle.getItemCount(i)==0 then 
			emptyLocation = i
		end
	end
	if(emptyLocation > -1 and turtle.getItemCount(emptyLocation)>0) then
		emptyLocation = -1
	end
	
end

local function goHomeAndBack()
	logger.log("Turtle is full, going back home to unload")
end

local function dropAllOresInChest()

end

local function checkInventory()
	getNextEmptyLocation()
	if emptyLocation == -1 then
		logger.log("[INV] - Turtle is full, dropping trash")
		for i=1,16 do
			if trash[turtle.getItemDetail(i).name] then
				logger.log("[INV] - "..turtle.getItemDetail(i).name.." marked as trash, dropping...")
				turtle.select(i)
				turtle.drop()
			else 
				logger.log("[INV] - "..turtle.getItemDetail(i).name.." not marked as trash, keeping it...")
			end
		end
		getNextEmptyLocation()
		if emptyLocation == -1 then
			logger.log("[INV] - Turtle is full of usefull things, putting ores in a chests")
			placeChestDown()
			
			
			
		end
		if debug then io.read() end
	else
		--logger.log("Turtle is not full")
	end
	turtle.select(1)
end


local function mineFU()
	turtle.forward()
	turtle.dig()
	checkInventory()
	turtle.digUp()
	checkInventory()
end

local function placeTorch()
	logger.log("Placing torch at "..curX)
	turtle.select(getNextTorch())
	turtle.place()
	torchCount = torchCount - 1
	if torchCount == 0 then
		logger.log("Turtle ran out of torches, will continue in the dark... (scary)")
	else
		logger.log("Torch placed, turtle has "..torchCount.." torches left.")
	end
	turtle.select(1)
end

local function mineFLR(torch)
	turtle.forward()
	turtle.dig()
	checkInventory()
	turtle.turnLeft()
	turtle.dig()
	if curX % 8 == 0 and torchCount > 0 and torch then
		placeTorch()
	end
	checkInventory()
	turtle.turnRight()
	turtle.turnRight()
	turtle.dig()
	if curX % 8 == 0  and torchCount > 0 and torch then
		placeTorch()
	end
	checkInventory()
	turtle.turnLeft()
end





local function createMainHall()
	getNextEmptyLocation()
	while curX < maxX do 
		mineFLR()
		curX = curX+1
	end

	turtle.digUp()
	checkInventory()
	turtle.up()
	curY=curY+1

	turtle.turnLeft()
	turtle.turnLeft()

	while curX > 0 do
		mineFLR(true)
		curX=curX-1
	end

	turtle.digDown()
	turtle.down()
	checkInventory()
	curY=curY-1

	logger.log("[Hall] - Back home: current location: "..curX..","..curY)

	turtle.turnLeft()
	turtle.turnLeft()

	if chestCount > 0 then
		placeChestDown()
	end
end




local function digBranches()
	turtle.turnLeft()
	-- left branch
	while curZ < maxZ do
		mineFU()
		curZ=curZ+1
	end
	turtle.turnLeft()
	turtle.turnLeft()
	while curZ > 0 do
		turtle.forward()
		curZ=curZ-1
	end

	-- right branch
	while curZ < maxZ do
		mineFU()
		curZ=curZ+1
	end
	turtle.turnLeft()
	turtle.turnLeft()
	while curZ > 0 do
		turtle.forward()
		curZ=curZ-1
	end
	turtle.turnRight()
end

local function createBranches()
	while curY > -1 do
		turtle.digDown()
		checkInventory()
		turtle.down()
		curY = curY -1
	end

	while curX < maxX do
		mineFLR()
		curX = curX+1
		if curX % 3 == 0 then	
			digBranches()
		end
	end
end

local function returnHome()
	turtle.turnLeft()
	turtle.turnLeft()
	while curX > 0 do
		turtle.forward()
		curX = curX -1
	end
	while curY < 0 do
		turtle.up()
		curY = curY +1
	end
	while curY > 0 do
		turtle.down()
		curY = curY -1
	end
	logger.log("Back home: current location: "..curX..","..curY)
end



-- Start
print("Hi There Welcome to Mining Turtle Program v"..version)
initializeLogger()
print("How deep should the branch mines be?")
input = io.read()
branchDepth = tonumber(input)

print("How many branches do you want?")
input = io.read()
branchNumber = tonumber(input)

print("Do you want to debug (y/n)?")
input = io.read()
while input ~= 'y' and input ~= 'n' do
	print("Do you want to debug (y/n)?")
	input = io.read()
end
if input=='y' then
	debug = true
elseif input =='n' then
	debug = false
else
	logger.log("error","Faulty response: this can never happen")
	io.read()
end


maxX = 3*branchNumber
maxZ = branchDepth+1
logger.log("[MAIN] - Max locations: "..maxX..","..maxZ)

logger.log("[MAIN] - Initializing Locations...")
initializeLocations()
logger.log("[MAIN] - Locations initailized, press any key to continue")
if debug then io.read() end
logger.log("[MAIN] - Checking fuel...")
checkFuel()
logger.log("[MAIN] - Checked fuel, press any key to continue")
if debug then io.read() end
logger.log("[MAIN] - Creating main hall... starting at location "..curX..","..curY)
createMainHall()
logger.log("[MAIN] - Main hall created, press any key to continue")
if debug then io.read() end
logger.log("[MAIN] - Creating branches...")
createBranches()
logger.log("[MAIN] - Branches created, press any key to continue")
if debug then io.read() end
logger.log("[MAIN] - Returning home...")
returnHome()
logger.log("[MAIN] - Returned home, press any key to continue")
if debug then io.read() end
turtle.down()
for i=1,16 do
	turtle.select(i)
	turtle.dropDown()
end
turtle.select(1)
