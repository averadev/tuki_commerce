local composer = require( "composer" )
local Sprites = require('src.Sprites')
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, grpBottom, rewardsH, grpHome, grpMsgH
local timerBottom, lblHPoints, lblHDesc, imgHReward, loading
local scene = composer.newScene()

-------------------------------------
-- Nuevo Usuario
-- @param item objeto usuario
------------------------------------
function toNewUser(item)
    composer.removeScene( "src.NewUser" )
    composer.gotoScene("src.NewUser", { time = 0, params = {user = item} })
    return true
end

-------------------------------------
-- Muestra pantalla Recompensas
-- @param item objeto usuario
------------------------------------
function toRewards(item)
    composer.removeScene( "src.Rewards" )
    composer.gotoScene("src.Rewards", { time = 0, params = {user = item} })
    return true
end

-------------------------------------
-- Muestra pantalla Recompensas
-- @param item objeto cajero
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
    if grpMsgH then
        grpMsgH:removeSelf()
        grpMsgH = nil
    end
    
    grpMsgH = display.newGroup()
    grpMsgH.alpha = 0
    screen:insert(grpMsgH)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsgH:insert(bgShadow)
    
    local imgBg = display.newImage( "img/invalidCard.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsgH:insert(imgBg)
    
    grpHome.alpha = 0
    transition.to( grpMsgH, { alpha = 1, time = 700 })
    transition.to( grpMsgH, { alpha = 0, time = 400, delay = 4000 })
    transition.to( grpHome, { alpha = 1, time = 400, delay = 4400 })
    return true
end

-------------------------------------
-- Mostramos Camara
-- @param event objeto evento
------------------------------------
function toCamera(event)
    audio.play( fxTap )
    if OpenCamera then
        OpenCamera.init()
    else
        --validate('1014858604001214') --User
        --validate('1013216233001528') --Cashier
        --validate('1014858604001210-16') --UserReward
    end
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
    loading:setSequence("stop")
    loading.alpha = 0
    transition.to( grpHome, { time = 500, alpha = 1 })
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
    
    grpHome = display.newGroup()
    grpHome.alpha = 0
    screen:insert(grpHome)
    
    local imgHomeText = display.newImage( "img/homeText.png" )
    imgHomeText.x = midW - 240 
    imgHomeText.y = 330 
    grpHome:insert(imgHomeText)
    
    local imgToCheckIn = display.newImage( "img/toCheckIn.png" )
    imgToCheckIn.x = midW + 260 
    imgToCheckIn.y = 330
    imgToCheckIn:addEventListener( 'tap', toCamera) 
    grpHome:insert(imgToCheckIn)
    
    local lbl1 = display.newText({
        text = "REGISTRA", 
        x = midW + 320, y = 300,
        width = 300,
        font = native.systemFontBold,   
        fontSize = 50, align = "left"
    })
    lbl1:setFillColor( 1 )
    grpHome:insert(lbl1)
    
    local lbl2 = display.newText({
        text = "TU  VISITA", 
        x = midW + 320, y = 360,
        width = 300,
        font = native.systemFont,   
        fontSize = 50, align = "left"
    })
    lbl2:setFillColor( 1 )
    grpHome:insert(lbl2)
    
    -- Bottom Section
    local bgBottom = display.newRoundedRect( midW, intH -110, intW - 20, 200, 10 )
    bgBottom:setFillColor( 0, 91/255, 127/255 )
    grpHome:insert( bgBottom )
    
    local bgPointsHome = display.newImage( "img/bgPointsHome.png" )
    bgPointsHome.x = 110
    bgPointsHome.y = intH - 110
    grpHome:insert(bgPointsHome)
    
    local bgImg = display.newRoundedRect( intW - 140, intH - 110, 240, 180, 10 )
    bgImg:setFillColor( 11/225, 163/225, 212/225 )
    grpHome:insert(bgImg)
    
    grpBottom = display.newGroup()
    grpHome:insert( grpBottom )
    
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
    
    local sheet = graphics.newImageSheet(Sprites.loading.source, Sprites.loading.frames)
    loading = display.newSprite(sheet, Sprites.loading.sequences)
    loading.x = midW
    loading.y = midH
    screen:insert(loading)
    loading:setSequence("play")
    loading:play()
    
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