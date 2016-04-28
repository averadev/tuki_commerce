local composer = require( "composer" )
local RestManager = require( "src.RestManager" )
local fxError = audio.loadSound( "fx/error.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, rewardsH
local scene = composer.newScene()


-------------------------------------
-- Regresamos a Home
------------------------------------
function toHome()
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
-- Muestra pantalla Recompensas
-- @param item objeto usuario
------------------------------------
function toCashier(item)
    composer.removeScene( "src.Cashier" )
    composer.gotoScene("src.Cashier", { time = 0, params = {user = item} })
    return true
end

-------------------------------------
-- Muestra pantalla obtener recompensa por qr
-- @param data objeto usuario/recompensa
------------------------------------
function toQrReward(data)
    composer.removeScene( "src.QrReward" )
    composer.gotoScene("src.QrReward", { time = 0, params = {data = data} })
    return true
end

-------------------------------------
-- Error QR Reward
------------------------------------
function qrError()
    local grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/invalidCard.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    transition.to( grpMsg, { alpha = 1, time = 700 })
    timer.performWithDelay( 4000, toHome )
    return true
end

-------------------------------------
-- Mostramos Camara
-- @param event objeto evento
------------------------------------
function getCamera(event)
    --local msg = OpenCamera.init()
    --native.showAlert( "TukiCommerce", msg, { "OK" } )
    return true
end

-------------------------------------
-- Validamos Codigo
-- @param event objeto evento
------------------------------------
function validate(qr)
    if string.len(qr) == 16 then
        RestManager.validateQR(qr)
    elseif string.len(qr) > 16 then
        RestManager.validateQrReward(qr)
    else
        invalidCard()
    end
    return true
end

-------------------------------------
-- Mensaje Tarjeta Invalida
------------------------------------
function invalidCard()
    local grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/invalidCard.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    transition.to( grpMsg, { alpha = 1, time = 1000 })
    audio.play( fxError)
    timer.performWithDelay( 4000, toHome )
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
    
    if OpenCamera then
        OpenCamera.init()
    end
    
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