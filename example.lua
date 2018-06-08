#!/usr/bin/env lua

package.path = package.path .. ";./?.lua"

local servicekit = require("servicekit")
local posix = require("posix")

--
-- Basic services that simply writes to a file periodically.
--


--
-- These upvalues hold the file we will write to, and if we will
-- continue to run.
--
local file
local run = true

servicekit.setup {

	--
	-- Startup: open the file. Log our pid to it (since by now, we
	-- will have detached) and our platform.
	--
	start = function()
		print("starting up!")
		file = io.open("/tmp/output.log", "w")
		file:write("My pid is: "..tostring(servicekit.pid()).."\n")
		file:write("platform: "..tostring(servicekit.platform).."\n")
	end,
	
	
	--
	-- Mainloop: write to the file.
	--
	run = function()
		while run do
			posix.sleep(2)
			file:write("new line\n")
			file:flush()
		end
	end,


	--
	-- Reloads the file. Try moving it, sending a sighup - and watch
	-- as the service now logs to a new one.
	--
	reload = function()
		print("reload!")
		file:write("Rotating logfile\n")
		file:close()
		file = io.open("/tmp/output.log", "w")
	end,
	

	--
	-- Send a sigterm, or a sigkill - and this gets called.
	-- Notice how this will stop the main loop.
	--
	-- You MUST implement this for graceful shutdowns to work with
	-- ServiceKit!
	--
	beginstop = function()
		run = false
	end,


	--
	-- Shutdown: cleanup by closing our file.
	--
	stop = function()
		file:write("stopping!\n")
		file:close()
	end
	
	}


--
-- And away we go...
--
servicekit.run()
