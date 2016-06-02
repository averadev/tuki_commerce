local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local screen
local userQrR, rewardQrR, grpQrR



-------------------------------------
-- Regresamos a Home
-- @param event objeto evento
------------------------------------
function tapReturn(event)
    composer.removeScene( "src.Home" )
    composer.gotoScene("src.Home", { time = 400, effect = "slideRight" })
    return true
end

-------------------------------------
-- Muestra pantalla Recompensas
-- @param item objeto cashier
------------------------------------
function toRewards(item)
    composer.removeScene( "src.Rewards" )
    composer.gotoScene("src.Rewards", { time = 0, params = {user = item} })
    return true
end

-------------------------------------
-- Redirige a Rewards
-- @param event objeto evento
------------------------------------
function cancelRedem(event)
    RestManager.validateQR(userQrR.id)
    return true
end

-------------------------------------
-- Confirma redencion
-- @param event objeto evento
------------------------------------
function confirmRedem(event)
    local grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/redemReward.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    transition.to( grpMsg, { alpha = 1, time = 700 })
    transition.to( grpQrR, { alpha = 0, time = 500, onComplete = function() 
        audio.play( fxCash )   
    end })
    timer.performWithDelay( 4000, tapReturn )
    
    -- Descontar puntos
    RestManager.insertRedemption(userQrR.id,  rewardQrR.id, rewardQrR.points)
    return true
end


-- Called immediately on call
function scene:create( event )
    screen = self.view
    userQrR = event.params.data.user
    rewardQrR = event.params.data.reward
    
    local imgBg = display.newImage( "img/bg.png" )
    imgBg.x = midW
    imgBg.y = midH
    screen:insert(imgBg)
    
    local imgClouds = display.newImage( "img/clouds.png" )
    imgClouds.anchorX = 0
    imgClouds.anchorY = 0
    screen:insert(imgClouds)
    
    local imgCorners = display.newImage( "img/corner.png" )
    imgCorners.anchorX = 1
    imgCorners.anchorY = 1
    imgCorners.x = intW
    imgCorners.y = intH
    screen:insert(imgCorners)
    
    grpQrR = display.newGroup()
    screen:insert(grpQrR)
    
    local btnBack = display.newImage( "img/btnBack.png" )
    btnBack.x = 170
    btnBack.y = 80
    btnBack:addEventListener( 'tap', tapReturn)
    grpQrR:insert(btnBack)
    
    local lblTitle = display.newText({
        text = "ESTAS POR OBTENER LA SIGUIENTE RECOMPENSA:", 
        x = midW, y = midH -200,
        fontSize = 28, width = 850, align = "left",
        font = native.systemFontBold,   
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( 1 )
    grpQrR:insert(lblTitle)
    
    local bgRew = display.newRoundedRect( midW, midH + 50, 920, 400, 10 )
    bgRew:setFillColor( unpack(cMarine) )
    grpQrR:insert( bgRew )
    
    local bgImg = display.newRoundedRect( midW - 200, midH + 50, 460, 350, 10 )
    bgImg:setFillColor( unpack(cAqua) )
    grpQrR:insert( bgImg )
    
    local imgReward = display.newImage( rewardQrR.image, system.TemporaryDirectory )
    imgReward.width = 440
    imgReward.height = 330
    imgReward.x = midW - 200
    imgReward.y = midH + 50
    grpQrR:insert(imgReward)
    
    local middlePoints = display.newImage( "img/middlePoints.png" )
    middlePoints.x = midW - 330
    middlePoints.y = midH + 169
    grpQrR:insert(middlePoints)
    
    local lblPoints = display.newText({
        text = rewardQrR.points, 
        x = midW - 330, y = midH + 169,
        fontSize = 50, font = native.systemFontBold
    })
    lblPoints:setFillColor( 1 )
    grpQrR:insert(lblPoints)
    
    local lblPointsD = display.newText({
        text = "PUNTOS", 
        x = midW - 330, y = midH + 200,
        fontSize = 20, font = native.systemFontBold
    })
    lblPointsD:setFillColor( 1 )
    grpQrR:insert(lblPointsD)
    
    local lblName = display.newText({
        text = rewardQrR.name, 
        x = midW + 250, y = midH - 120,
        fontSize = 28, width = 400, align = "left",
        font = native.systemFontBold
    })
    lblName.anchorY = 0
    lblName:setFillColor( 1 )
    grpQrR:insert(lblName)
    
    local posYD = (midH-110) + lblName.height
    
    local lblDesc = display.newText({
        text = rewardQrR.description, 
        x = midW + 250, y = posYD,
        fontSize = 22, width = 400, align = "left",
        font = native.systemFont, height = 200
    })
    lblDesc.anchorY = 0
    lblDesc:setFillColor( 1 )
    grpQrR:insert(lblDesc)
    
    local bgCancelW = display.newRoundedRect( midW + 140, midH + 175, 200, 100, 10 )
    bgCancelW:setFillColor( 1 )
    grpQrR:insert( bgCancelW )
    local bgCancel = display.newRoundedRect( midW + 140, midH + 175, 190, 90, 10 )
    bgCancel:setFillColor( unpack(cAquaH) )
    bgCancel:addEventListener( 'tap', cancelRedem)
    grpQrR:insert( bgCancel )
    
    local bgRedemW = display.newRoundedRect( midW + 350, midH + 175, 200, 100, 10 )
    bgRedemW:setFillColor( 1 )
    grpQrR:insert( bgRedemW )
    local bgRedem = display.newRoundedRect( midW + 350, midH + 175, 190, 90, 10 )
    bgRedem:setFillColor( unpack(cAqua) )
    bgRedem:addEventListener( 'tap', confirmRedem)
    grpQrR:insert( bgRedem )
    
    local lblConfirmar1 = display.newText({
        text = "No, ver otras recompensas", 
        x = midW + 140, y = midH + 175, width = 170,
        fontSize = 25, font = native.systemFont, align = 'center'
    })
    lblConfirmar1:setFillColor( .1 )
    grpQrR:insert(lblConfirmar1)
    
    local lblConfirmar = display.newText({
        text = "¡CONFIRMAR!", 
        x = midW + 350, y = midH + 175,
        fontSize = 25, font = native.systemFontBold
    })
    lblConfirmar:setFillColor( .1 )
    grpQrR:insert(lblConfirmar)
    
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
end

-- Hide scene
function scene:hide( event )
end

-- Destroy scene
function scene:destroy( event )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene