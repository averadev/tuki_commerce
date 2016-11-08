local composer = require( "composer" )
local Sprites = require('src.Sprites')
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, grpBottom, rewardsH, grpHome, grpMsgH, grpMsgM, grpMsgS
local timerBottom, lblHPoints, lblHDesc, imgHReward, loading, txtExit, itsPoints = false
local scene = composer.newScene()

-------------------------------------
-- Nuevo Usuario
-- @param item objeto usuario
------------------------------------
function toLogin()
    composer.removeScene( "src.Login" )
    composer.gotoScene("src.Login", { time = 0 })
    return true
end

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
function qrError(isCashier)
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
    
    local errorImg = "invalidCard.png"
    if isCashier then
        errorImg = "invalidCardCashier.png"
    end
    
    local imgBg = display.newImage( "img/"..errorImg )
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
    -- Validas conexion
    if RestManager.networkConnection() then
        audio.play( fxTap )
        if OpenCamera then
            OpenCamera.init()
        else
            --validate('4000000000001641') --User
            validate('1021238449002901') --Cashier
            --validate('4000000000001641-27') --UserReward
        end
    else
        showMsg("Asegurese de estar conectado a internet")
    end
    return true
end

-------------------------------------
-- Validamos Codigo
-- @param event objeto evento
------------------------------------
function validate(qr)
    if itsPoints then
        itsPoints = false
        RestManager.checkPoints(qr)
    elseif string.len(qr) == 16 then
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
    imgHReward.height = 204
    imgHReward.width = 272
    imgHReward.x = intW - 160
    imgHReward.y = intH - 140
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

-------------------------------------
-- Cierra modal
-- @param event objeto evento
------------------------------------
function closeMod(event)
    native.setKeyboardFocus(nil)
    transition.to( grpMsgS, { alpha = 0, time = 400, onComplete = function()
        if txtExit then
            txtExit:removeSelf()
            txtExit = nil
        end
    end} )
end

-------------------------------------
-- Validar salida
-- @param event objeto evento
------------------------------------
function onTxtExit(event)
    print(event.phase)
    if ( "submitted" == event.phase ) then
        RestManager.validateExit(txtExit.text)
        closeMod()
    end
end

-------------------------------------
-- Muestra los puntos disponibles
-- @param isLoading activar/desactivar
------------------------------------
function showPoints(points)
    if grpMsgM then
        grpMsgM:removeSelf()
        grpMsgM = nil
    end

    grpMsgM = display.newGroup()
    grpMsgM.alpha = 0
    screen:insert(grpMsgM)

    function setDes(event)
        return true
    end
    local bg = display.newRect( midW, midH, intW, intH )
    bg:addEventListener( 'tap', setDes)
    bg:setFillColor( 0 )
    bg.alpha = .7
    grpMsgM:insert(bg)
    
    local bgPoints = display.newImage( "img/bgPointsHome.png" )
    bgPoints:translate(midW, midH)
    bgPoints.height = 300
    bgPoints.width = 300
    grpMsgM:insert(bgPoints)

    local lblMsg1 = display.newText({
        text = points, 
        x = midW, y = midH - 30,
        fontSize = 110, align = "center",
        font = fontBold
    })
    lblMsg1:setFillColor( unpack(cWhite) )
    grpMsgM:insert(lblMsg1)

    local lblMsg2 = display.newText({
        text = "PUNTOS", 
        x = midW, y = midH + 60,
        fontSize = 40, align = "center",
        font = fontSemiRegular
    })
    lblMsg2:setFillColor( unpack(cWhite) )
    grpMsgM:insert(lblMsg2)
    
    transition.to( grpMsgM, { alpha = 1, time = 400 } )
    transition.to( grpMsgM, { alpha = 0, time = 400, delay = 2000 } )
end

-------------------------------------
-- Muestra loading sprite
-- @param isLoading activar/desactivar
------------------------------------
function showMsg(message)
    if grpMsgM then
        grpMsgM:removeSelf()
        grpMsgM = nil
    end

    grpMsgM = display.newGroup()
    grpMsgM.alpha = 0
    screen:insert(grpMsgM)

    function setDes(event)
        return true
    end
    local bg = display.newRect( midW, midH, intW, intH )
    bg:addEventListener( 'tap', setDes)
    bg:setFillColor( 0 )
    bg.alpha = .3
    grpMsgM:insert(bg)

    local bg = display.newRoundedRect( midW, midH, 404, 154, 15 )
    bg:setFillColor( unpack(cTurquesa) )
    grpMsgM:insert(bg)

    local bg = display.newRoundedRect( midW, midH, 400, 150, 15 )
    bg:setFillColor( unpack(cWhite) )
    grpMsgM:insert(bg)

    local lblMsg = display.newText({
        text = message, 
        x = midW, y = midH, width = 380, 
        fontSize = 27, align = "center",
        font = fontSemiBold
    })
    lblMsg:setFillColor( unpack(cPurPle) )
    grpMsgM:insert(lblMsg)
    
    transition.to( grpMsgM, { alpha = 1, time = 400 } )
    transition.to( grpMsgM, { alpha = 0, time = 400, delay = 2000 } )
end

-------------------------------------
-- Autentificar salida
-- @param isLoading activar/desactivar
------------------------------------
function showExit()
    if grpMsgS then
        grpMsgS:removeSelf()
        grpMsgS = nil
    end

    grpMsgS = display.newGroup()
    grpMsgS.alpha = 0
    screen:insert(grpMsgS)

    function setDes(event)
        return true
    end
    local bg = display.newRect( midW, midH, intW, intH )
    bg:addEventListener( 'tap', setDes)
    bg:setFillColor( 0 )
    bg.alpha = .3
    grpMsgS:insert(bg)

    local bg = display.newRoundedRect( midW, 150, 578, 228, 10 )
    bg:setFillColor( unpack(cTurquesa) )
    grpMsgS:insert(bg)

    local bg2 = display.newRoundedRect( midW, 150, 570, 220, 10 )
    bg2:setFillColor( unpack(cWhite) )
    grpMsgS:insert(bg2)
    
    local iconClose = display.newImage( "img/iconClose.png" )
    iconClose:translate(midW + 250, 65)
    iconClose:addEventListener( 'tap', closeMod)
    grpMsgS:insert(iconClose)
    
    -- Bg TextFields
    local bgField1 = display.newRoundedRect( midW, 125, 474, 74, 5 )
    bgField1:setFillColor( unpack(cTurquesa) )
    grpMsgS:insert( bgField1 )
    local bgField2 = display.newRoundedRect( midW, 125, 470, 70, 5 )
    bgField2:setFillColor( unpack(cWhite) )
    grpMsgS:insert( bgField2 )
    local bgSignPass = display.newImage("img/iconCandado.png", true) 
    bgSignPass.x = midW - 200
    bgSignPass.y = 125
    grpMsgS:insert(bgSignPass)
    
    -- TextField
    txtExit = native.newTextField( midW + 20, 125, 400, 45 )
    txtExit.size = 23
    txtExit.isSecure = true
    txtExit.hasBackground = false
    txtExit.placeholder = "Clave sucursal"
    txtExit:addEventListener( "userInput", onTxtExit )
	grpMsgS:insert(txtExit)
    
    -- Boton Salir
    local btnAccess = display.newRoundedRect( midW, 210, 470, 55, 5 )
    btnAccess:setFillColor( unpack(cTurquesa) )
    btnAccess:addEventListener( 'tap', function()
        RestManager.validateExit(txtExit.text)
        closeMod()
    end)
    grpMsgS:insert( btnAccess )
    local lblAccess = display.newText({
        text = "LOGOUT", 
        x = midW, y = 210, 
        fontSize = 30, width = 300,
        font = fontSemiBold, align = 'center'

    })
    lblAccess:setFillColor( unpack(cWhite) )
    grpMsgS:insert(lblAccess)
    
    transition.to( grpMsgS, { alpha = 1, time = 400 } )
end

-------------------------------------
-- Muestra loading sprite
-- @param isLoading activar/desactivar
------------------------------------
function showMsgE(message)
    if grpMsgM then
        grpMsgM:removeSelf()
        grpMsgM = nil
    end

    grpMsgM = display.newGroup()
    grpMsgM.alpha = 0
    screen:insert(grpMsgM)

    function setDes(event)
        return true
    end
    local bg0 = display.newRect( midW, midH, intW, intH )
    bg0:addEventListener( 'tap', setDes)
    bg0:setFillColor( 0 )
    bg0.alpha = .3
    grpMsgM:insert(bg0)

    local bg = display.newRoundedRect( midW, midH + 25, 404, 204, 15 )
    bg:setFillColor( 1 )
    grpMsgM:insert(bg)

    local bg1 = display.newRoundedRect( midW, midH + 25, 400, 200, 15 )
    bg1:setFillColor( unpack(cMarine) )
    grpMsgM:insert(bg1)

    local lblMsg = display.newText({
        text = message, 
        x = midW, y = midH - 20, width = 380, 
        fontSize = 27, align = "center",
        font = fontSemiBold
    })
    lblMsg:setFillColor( 1 )
    grpMsgM:insert(lblMsg)

    function retry(event)
        -- Verify connection
        if RestManager.networkConnection() then
            RestManager.getRewards()
            transition.to( grpMsgM, { alpha = 0, time = 400 } )
        else
            transition.to( grpMsgM, { alpha = 0, time = 400 } )
            transition.to( grpMsgM, { alpha = 1, time = 400, delay = 400 } )
        end
        return true
    end
    local bg2 = display.newRoundedRect( midW, midH + 60, 200, 60, 15 )
    bg2:setFillColor( unpack(cAquaH) )
    bg2:addEventListener( 'tap', retry)
    grpMsgM:insert(bg2)

    local lblMsgR = display.newText({
        text = "Reintentar", 
        x = midW, y = midH + 60, width = 380, 
        fontSize = 27, align = "center",
        font = fontSemiBold
    })
    lblMsgR:setFillColor( 1 )
    grpMsgM:insert(lblMsgR)
    
    transition.to( grpMsgM, { alpha = 1, time = 400 } )
end

-- Called immediately on call
function scene:create( event )
    screen = self.view
    local xtraW = 0
    if intW > 1050 then
        xtraW = (intW - 1050) / 5
    end
    
    local bg = display.newRect( midW, midH, intW, intH )
    bg:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } ) 
    screen:insert(bg)
    
    local iconExit = display.newImage( "img/iconExit.png" )
    iconExit.x = 30
    iconExit.y = 40
    iconExit:addEventListener( 'tap', showExit) 
    screen:insert(iconExit)
    
    local iconPoints = display.newImage( "img/iconPoints.png" )
    iconPoints.x = intW - 30
    iconPoints.y = 40
    iconPoints:addEventListener( 'tap', function()
        itsPoints = true
        toCamera()
    end) 
    screen:insert(iconPoints)
    
    grpHome = display.newGroup()
    grpHome.alpha = 0
    screen:insert(grpHome)
    
    local logoTuki = display.newImage( "img/logoTuki.png" )
    logoTuki.x = (midW - xtraW) - 240 
    logoTuki.y = midH - 50
    grpHome:insert(logoTuki)
    
    local phone = display.newImage( "img/phone.png" )
    phone.x = (midW - xtraW) - 240 
    phone.y = midH + 120
    grpHome:insert(phone)
    
    local lbl1 = display.newText({
        text = "GANA RECOMPENSAS", 
        x = (midW + xtraW) + 280, y = midH - 250,
        width = 400,
        font = fontBold,   
        fontSize = 35, align = "center"
    })
    lbl1:setFillColor( 1 )
    grpHome:insert(lbl1)
    
    local lbl2 = display.newText({
        text = "EN TUS COMPRAS...", 
        x = (midW + xtraW) + 280, y = midH - 200,
        width = 400,
        font = fontRegular,   
        fontSize = 35, align = "center"
    })
    lbl2:setFillColor( 1 )
    grpHome:insert(lbl2)
    
    local stores = display.newImage( "img/stores.png" )
    stores.x = (midW + xtraW) + 280 
    stores.y = midH - 110
    grpHome:insert(stores)
    
    local imgToCheckIn = display.newImage( "img/toCheckIn.png" )
    imgToCheckIn.x = (midW + xtraW) + 280 
    imgToCheckIn.y = midH + 30
    imgToCheckIn:addEventListener( 'tap', toCamera) 
    grpHome:insert(imgToCheckIn)
    
    -- Bottom Section
    local bgBottom1 = display.newRect( midW, intH -140, intW, 204 )
    bgBottom1:setFillColor( unpack(cTurquesa) )
    grpHome:insert( bgBottom1 )
    local bgBottom2 = display.newRect( midW, intH -140, intW, 200 )
    bgBottom2:setFillColor( unpack(cPurPle) )
    grpHome:insert( bgBottom2 )
    
    local bgPointsHome = display.newImage( "img/bgPointsHome.png" )
    bgPointsHome.x = 110
    bgPointsHome.y = intH - 140
    grpHome:insert(bgPointsHome)
    
    local bgImg = display.newRoundedRect( intW - 160, intH - 140, 282, 214, 10 )
    bgImg:setFillColor( 11/225, 163/225, 212/225 )
    grpHome:insert(bgImg)
    
    grpBottom = display.newGroup()
    grpHome:insert( grpBottom )
    
    lblHPoints = display.newText({
        text = "", 
        x = 110, y = intH - 165,
        width = 150,
        font = fontSemiBold,   
        fontSize = 70, align = "center"
    })
    lblHPoints:setFillColor( unpack(cWhite) )
    grpBottom:insert(lblHPoints)
    
    lblHPoints2 = display.newText({
        text = "PUNTOS", 
        x = 110, y = intH - 110,
        width = 150,
        font = fontSemiBold,   
        fontSize = 30, align = "center"
    })
    lblHPoints2:setFillColor( unpack(cWhite) )
    grpBottom:insert(lblHPoints2)
    
    lblHDesc = display.newText({
        text = "", 
        x = midW - 35, y = intH - 140, width = intW - 530,
        font = fontSemiBold,   
        fontSize = 50, align = "left"
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
    
    -- Verify connection
    if RestManager.networkConnection() then
        RestManager.reloadConfig()
        RestManager.getRewards()
    else
        showMsgE("Asegurese de estar conectado a internet")
    end
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