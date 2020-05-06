-- This Version

-- 06/05/2020
-- DrJoachim


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
local distance = 0 -- How Far Did User Pick
local onlight = 0 -- When to Place Torch

local torchCount = 0 -- Tracks the number of torches
local chestCount = 0 -- Tracks the number of chests
local fuelCount = 0 -- Tracks the number of fuelItems

local MD = 3 -- How Many Blocks Apart From Each Mine
local MineTimes = 0 -- If Multi Mines Are ON then This will keep Count
local Fuel = 0 -- if 2 then it is unlimited no fuel needed
local NeedFuel = 0 -- If Fuel Need Then 1 if not Then 0
local Error = 0 -- 0 = No Error and 1 = Error
local Way = 0 -- 0 = Left and 1 = Right
local version = '0.04'

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
				-- Found torch location
				logger.log("Found torch location "..i)
				 torchCount = torchCount + turtle.getItemCount(i)
			elseif string.find(details.name,"chest") then
				logger.log("Found chest location "..i)
				chestCount = chestCount + turtle.getItemCount(i)
			elseif turtle.refuel(0) then
				logger.log("Found fuel location "..i)
				fuelCount = fuelCount + turtle.getItemCount(i)
			end
		end
	end
	turtle.select(1)
	logger.log("Found "..torchCount.." torches.")
	logger.log("Found "..chestCount.." chests.")
	logger.log("Found "..fuelCount.." fuel items.")
end

--Checking
local function Check()

	
	


	if torch == 0 then
		print("There are no torch's in Turtle")
		Error = 1
	else
		print("There are torch's in turtle")
	end
	if chest == 0 then
		print("there are no chests")
		Error = 1
	else
		print("There are chest in turtle")
	end
	if ItemFuel == 0 then
		print("No Fuel Items")
		Error = 1
	else
		print("there is fuel")
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
		elseif NeedFuel == 1 then
			Needfuel = 0
		end
	until NeedFuel == 0
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
	os.loadApi("logger")
end

-- Start
print("Hi There Welcome to Mining Turtle Program "..version)
print("How Far Will Turtle Go")
input = io.read()
distance = tonumber(input)
TF = distance
TB = distance
initializeLogger()
initializeLocations()
-- print("How Many Times")
-- input3 = io.read()
-- MineTimes = tonumber(input3)
-- Check()
-- if Error == 1 then 
-- 	repeat
-- 		sleep(10)
-- 		Recheck()
-- 		Check()
-- 	until Error == 0
-- end
-- Start()