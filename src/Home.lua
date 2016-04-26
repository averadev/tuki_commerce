local composer = require( "composer" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, grpBottom, rewardsH
local timerBottom, lblHPoints, lblHDesc, imgHReward
local scene = composer.newScene()

-------------------------------------
-- Mostramos Camara
-- @param event objeto evento
------------------------------------
function toCamera(event)
    audio.play( fxTap )
    composer.removeScene( "src.Camera" )
    composer.gotoScene("src.Camera", { time = 0 })
    return true
end

-------------------------------------
-- Cambiamos detalle de a recompensa
-- @param event objeto evento
------------------------------------
function changeReward()
    
    local random = math.random(#rewardsH)
    lblHPoints.text = rewardsH[random].points
    lblHDesc.text = rewardsH[random].name
    
    if imgHReward then
        imgHReward:removeSelf()
        imgHReward = nil
    end
    imgHReward = display.newImage( rewardsH[random].image, system.TemporaryDirectory )
    imgHReward.height = 171
    imgHReward.width = 228
    imgHReward.x = intW - 140
    imgHReward.y = intH - 110
    grpBottom:insert(imgHReward)
    
    grpBottom.alpha = 0
    transition.to( grpBottom, { alpha = 1, time = 1000 })
    
    return true
end

-------------------------------------
-- Mostramos recompensas
-- @param items lista de recompensas
------------------------------------
function homeRewards(items)
    rewardsH = items
    changeReward()
    timerBottom = timer.performWithDelay( 10000, changeReward, 0 )
end

-- Called immediately on call
function scene:create( event )
    screen = self.view
    
    local imgBg = display.newImage( "img/bg.png" )
    imgBg.x = midW
    imgBg.y = midH
    screen:insert(imgBg)
    
    local imgClouds = display.newImage( "img/clouds.png" )
    imgClouds.anchorX = 0
    imgClouds.anchorY = 0
    screen:insert(imgClouds)
    
    local imgHomeText = display.newImage( "img/homeText.png" )
    imgHomeText.x = midW - 240 
    imgHomeText.y = 330 
    screen:insert(imgHomeText)
    
    local imgToCheckIn = display.newImage( "img/toCheckIn.png" )
    imgToCheckIn.x = midW + 260 
    imgToCheckIn.y = 330
    imgToCheckIn:addEventListener( 'tap', toCamera) 
    screen:insert(imgToCheckIn)
    
    local lbl1 = display.newText({
        text = "REGISTRA", 
        x = midW + 320, y = 300,
        width = 300,
        font = native.systemFontBold,   
        fontSize = 50, align = "left"
    })
    lbl1:setFillColor( 1 )
    screen:insert(lbl1)
    
    local lbl2 = display.newText({
        text = "TU  VISITA", 
        x = midW + 320, y = 360,
        width = 300,
        font = native.systemFont,   
        fontSize = 50, align = "left"
    })
    lbl2:setFillColor( 1 )
    screen:insert(lbl2)
    
    -- Bottom Section
    local bgBottom = display.newRoundedRect( midW, intH -110, intW - 20, 200, 10 )
    bgBottom:setFillColor( 0, 91/255, 127/255 )
    screen:insert( bgBottom )
    
    local bgPointsHome = display.newImage( "img/bgPointsHome.png" )
    bgPointsHome.x = 110
    bgPointsHome.y = intH - 110
    screen:insert(bgPointsHome)
    
    local bgImg = display.newRoundedRect( intW - 140, intH - 110, 240, 180, 10 )
    bgImg:setFillColor( 11/225, 163/225, 212/225 )
    screen:insert(bgImg)
    
    grpBottom = display.newGroup()
    screen:insert( grpBottom )
    
    lblHPoints = display.newText({
        text = "", 
        x = 110, y = intH - 125,
        width = 150,
        font = native.systemFontBold,   
        fontSize = 70, align = "center"
    })
    lblHPoints:setFillColor( unpack(cMarine) )
    grpBottom:insert(lblHPoints)
    
    lblHDesc = display.newText({
        text = "", 
        x = midW - 30, y = intH - 110, width = intW - 500,
        font = native.systemFontBold,   
        fontSize = 55, align = "left"
    })
    lblHDesc:setFillColor( 1 )
    grpBottom:insert(lblHDesc)
    
    RestManager.getRewards()
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
    
end

-- Hide scene
function scene:hide( event )
    if ( event.phase == "will" ) then
        timer.cancel(timerBottom)
    end
    
end

-- Destroy scene
function scene:destroy( event )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene