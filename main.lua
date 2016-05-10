-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local DBManager = require('src.DBManager')
local composer = require( "composer" )


local function onSystemEvent(event)
    print("event.type:"..event.type)
	if event.type == "applicationResume" and "src.Home" == composer.getSceneName( "current" )then
        config = DBManager.getSettings() 
        print("config:"..config.qr)
        if config.qr == '' then
        else
            print("Corona: "..config.qr)
            DBManager.clearQR()
            validate(config.qr)
        end
    end
end
Runtime:addEventListener("system", onSystemEvent) 


DBManager.setupSquema() 
composer.gotoScene("src.Home")