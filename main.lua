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
	if event.type == "applicationResume" and 
        ("src.Home" == composer.getSceneName( "current" )
        or "src.Cash" == composer.getSceneName( "current" ) )then
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
local dbConfig = DBManager.getSettings()
if dbConfig.idBranch == 0 then
    composer.gotoScene("src.Login")
else
    composer.gotoScene("src.Home")
end
