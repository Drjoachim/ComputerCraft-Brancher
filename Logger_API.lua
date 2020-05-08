function log( Str1, Str2 )
	-- instructions
	-- To write in you log (file) use this: log("Message"), is there a error? Use this: log("error", "Message")
	-- settings
	local logfile="/Logfile.txt" -- This is the destination where the logs and errors in writed.
	local logfiledisable=true -- To turn of the log file, change this to 'false'.
	local erroronly=false -- If this setting on 'true' then putt only errors in the log file.
	local screenlog=true -- This setting show the log file on the computer screen, to turn it off, change this to 'false'.
	local timedate=true -- This setting can you change the time to 24h or 12h (AM/PM). True = 24h, false = 12h (AM/PM)
	local senderror=false -- If this settings on 'true' then send the errors to a computer. You must be installed a rednet modem!
		local senderrorid=0 -- Change this to the ID where the errors send to.
		local closemodem=true -- This setting will close the modem after send error report.
	-- script
	if logfiledisable == true and not fs.exists(logfile) then
		local file=fs.open(logfile, "w")
		file.writeLine("-- Log script by iRichard --")
		file.writeLine("Log created on day: "..os.day().." at "..textutils.formatTime(os.time(), timedate).." (in-game time).")
		file.writeLine("Computer ID: "..os.getComputerID())
		file.writeLine("------------")
		file.close()
	end	

	if screenlog == true then
		if Str1 == "error" then
			if term.isColour() then
				term.setTextColor(colors.red)
			end
			print("[ERROR:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] "..Str2)
			if term.isColour() then
				term.setTextColor(colors.white)
			end
			if logfiledisable == true then
				local file=fs.open(logfile, "a")
				file.writeLine("[ERROR:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] "..Str2)
				file.close()
			end
			if senderror == true then
				for _, autoside in pairs(rs.getSides()) do
					if peripheral.getType(autoside) == "modem" then rednet.open(autoside) present = true break end
				end
				autoside = false
				if rednet.isOpen(autoside) == true then
					rednet.send(senderrorid, "[ERROR (ID:"..os.getComputerID()..":"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] "..Str2)
					if closemodem == true then
						rednet.close(autoside)
					end
				else
					if term.isColour() then
						term.setTextColor(colors.red)
					end
					print("[ERROR:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] Error report not send! Rednet modem isn't open or not installed.")
					term.setTextColor(colors.white)
					if logfiledisable == true then
						if not fs.exists(logfile) then
							local file=fs.open(logfile, "w")
							file.writeLine("-- Log script by iRichard980 --")
							file.writeLine("Log created on day: "..os.day().." at "..textutils.formatTime(os.time(), timedate).." (in-game time).")
							file.writeLine("Computer ID: "..os.getComputerID())
							file.writeLine("------------")
							file.close()
						end
						local file=fs.open(logfile, "a")
						file.writeLine("[ERROR:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] Error report not send! Rednet modem isn't open or not installed.")
						file.close()
					end
				end
			end
		else
			print("[LOG:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] "..Str1)
			if logfiledisable == true and erroronly == false then
				if not fs.exists(logfile) then
					local file=fs.open(logfile, "w")
					file.writeLine("-- Log script by iRichard980 --")
					file.writeLine("Log created on day: "..os.day().." at "..textutils.formatTime(os.time(), timedate).." (in-game time).")
					file.writeLine("Computer ID: "..os.getComputerID())
					file.writeLine("------------")
					file.close()
				end
				local file=fs.open(logfile, "a")
				file.writeLine("[LOG:"..os.day().."-"..textutils.formatTime(os.time(), timedate).."] "..Str1)
				file.close()
			end
		end
	end
end