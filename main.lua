-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local DBManager = require('src.DBManager')
local composer = require( "composer" )


local function onSystemEvent(event)
	if event.type == "applicationResume" and "src.Camera" == composer.getSceneName( "current" )then
        config = DBManager.getSettings() 
        if config.qr == '' then
            composer.removeScene( "src.Home" )
            composer.gotoScene("src.Home", { time = 400, effect = "slideRight" })
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