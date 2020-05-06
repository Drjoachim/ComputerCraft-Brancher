-- This Version

-- 06/05/2020
-- DrJoachim
local version = '0.05'

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
local branchDepth = 0 -- How deep Did User Pick
local branchNumber = 0 -- How many branches does the user want?

local torchCount = 0 -- Tracks the number of torches
local torchLocations = {}

local chestCount = 0 -- Tracks the number of chests
local chestLocations = {}

local fuelCount = 0 -- Tracks the number of fuelItems
local fuelLocations = {}

local MD = 3 -- How Many Blocks Apart From Each Mine

local onlight = 0 -- When to Place Torch
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error
local Way = 0 -- 0 = Left and 1 = Right


local trash = {
	["minecraft:cobblestone"] = true,
	["minecraft:dirt"] = true,
	["minecraft:gravel"] = true,
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
	logger.log("*********************Locations****************************")
	logger.log("Found "..torchCount.." torches on these locations: "..torchLocations)
	logger.log("Found "..chestCount.." chests on these locations: "..chestLocations)
	logger.log("Found "..fuelCount.." fuel items on these locations: "..fuelLocations)
	logger.log("*******************************************************")
end

--Checking
local function Check()
	local branchSteps = branchDepth * 2 * branchNumber
	local mainSteps = 9 * branchNumber
	local totalSteps = branchSteps + mainSteps
	logger.log("totalsteps = "..totalSteps)
	if turtle.getFuelLevel() == "unlimited" then 
		logger.log("No need for fuel")
		
	elseif  turtle.getFuelLevel() >= totalSteps then
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
			logger.log("fuel level is now "..turtle.getFuelLevel)
		end
	end

end

-- Recheck if user forget something turtle will check after 15 sec
local function Recheck()
	torch = turtle.getItemCount(1)
	chest = turtle.getItemCount(2)
	ItemFuel = turtle.getItemCount(3)
	Error = 0
end

--Mining
local function ForwardM()
	repeat
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then -- sometimes sand and gravel and block and mix-up distance
			TF = TF - 1
			onlight = onlight + 1
		end
		if turtle.detectUp() then
			turtle.digUp()
		end
		turtle.select(4)
		turtle.placeDown()
		if onlight == 8 then -- Every 10 Block turtle place torch
			if torch > 0 then
				turtle.turnLeft()
				turtle.turnLeft()
				turtle.select(1)
				turtle.place()
				turtle.turnLeft()
				turtle.turnLeft()
				torch = torch - 1
				onlight = onlight - 8
			else
				print("turtle run out of torchs")
				os.shutdown()
			end
		end
		if turtle.getItemCount(16)>0 then -- If slot 16 in turtle has item slot 5 to 16 will go to chest
			if chest > 0 then
				turtle.select(2)
				turtle.digDown()
				turtle.placeDown()
				chest = chest - 1
				for slot = 5, 16 do
					turtle.select(slot)
					turtle.dropDown()
					sleep(1.5)
				end
				turtle.select(5)
			else
				print("turtle run out of chest")
				os.shutdown()
			end
		end
		repeat
			if turtle.getFuelLevel() == "unlimited" then 
				print("NO NEED FOR FUEL")
				Needfuel = 0
			elseif turtle.getFuelLevel() < 100 then
				turtle.select(3)
				turtle.refuel(1)
				Needfuel = 1
				ItemFuel = ItemFuel - 1
			elseif ItemFuel == 0 then
				print("turtle run out of fuel")
				os.shutdown()
			elseif NeedFuel == 1 then
				Needfuel = 0
			end
		until NeedFuel == 0
	until TF == 0
end

--Warm Up For Back Program
local function WarmUpForBackProgram() -- To make turn around so it can go back
	turtle.turnLeft()
	turtle.turnLeft()
	turtle.up()
end

--Back Program
local function Back()
	repeat
		if turtle.forward() then -- sometimes sand and gravel and block and mix-up distance
			TB = TB - 1
		end
		if turtle.detect() then -- Sometimes sand and gravel can happen and this will fix it
			if TB ~= 0 then
				turtle.dig()
			end
		end
	until TB == 0
end

-- Multimines Program
local function MultiMines()
	if Way == 1 then
		turtle.turnLeft()
		turtle.down()
	else
		turtle.turnRight()
		turtle.down()
	end
	repeat
		if turtle.detect() then
			turtle.dig()
		end
		if turtle.forward() then
			MD = MD - 1
		end
		if turtle.detectUp() then
			turtle.digUp()
		end
	until MD == 0
	if Way == 1 then
		turtle.turnLeft()
	else
		turtle.turnRight()
	end
	if MineTimes == 0 then
		print("Turtle is done")
	else
		MineTimes = MineTimes - 1
	end
end

-- Restart 
local function Restart()
	TF = distance
	TB = distance
	MD = 3
	onlight = 0
end

-- Starting 
function Start()
	repeat
		ForwardM()
		WarmUpForBackProgram()
		Back()
		MultiMines()
		Restart()
	until MineTimes == 0
end

function initializeLogger()
	--pastebin get J2bF3fpf logger
	os.loadAPI("logger")
end

-- Start
print("Hi There Welcome to Mining Turtle Program v"..version)
print("How deep should the branch mines be?")
input = io.read()
branchDepth = tonumber(input)

print("How many branches do you want?")
input = io.read()
branchNumber = tonumber(input)

initializeLogger()
initializeLocations()

Check()
-- if Error == 1 then 
-- 	repeat
-- 		sleep(10)
-- 		Recheck()
-- 		Check()
-- 	until Error == 0
-- end
-- Start()