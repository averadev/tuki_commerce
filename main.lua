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
local dbConfig = DBManager.getSettings()
if dbConfig.idBranch == 0 then
    composer.gotoScene("src.Login")
else
    composer.gotoScene("src.Cash")
    local item = {}
    item.id = 4000000000001641
    item.points = 70
    item.newPoints = 0
    --composer.gotoScene("src.Rewards", { time = 0, params = {user = item} })
end
