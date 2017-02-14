-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
require('src.Globals')
local DBManager = require('src.DBManager')
local composer = require( "composer" )
position = system.orientation

local function onSystemEvent(event)
	if event.type == "applicationResume" and 
        ("src.Home" == composer.getSceneName( "current" )
        or "src.Cash" == composer.getSceneName( "current" ) )then
        config = DBManager.getSettings()
        print("QR: ",config.qr)
        if config.qr == '' then
        else
            DBManager.clearQR()
            validate(config.qr)
        end
    end
end
Runtime:addEventListener("system", onSystemEvent) 


local function onOrientationChange( event )
	position = event.type
    rotateScr()
	
end
--Runtime:addEventListener( "orientation", onOrientationChange )


DBManager.setupSquema() 
local dbConfig = DBManager.getSettings()
if dbConfig.idBranch == 0 then
    composer.gotoScene("src.Login")
else
    composer.gotoScene("src.Home")
    
    --composer.gotoScene("src.Cash")
    
    --[[ 
    item = {}
    item.id = 4000000000001641
    item.points = 100
    item.newPoints = 0
    composer.gotoScene("src.Rewards", { time = 0, params = {user = item} })
    ]]
    
    --[[ 
    item = {}
    item.id = 1021444472002964
    composer.gotoScene("src.Cashier", { time = 0, params = {user = item} })
    ]]
end
