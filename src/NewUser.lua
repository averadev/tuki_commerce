local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local screen, grpNewUser, itemNU, lblTitleNU
local bgNombreR, bgPassR, txtName, txtEmail

-------------------------------------
-- Muestra pantalla Recompensas
-- @param item objeto usuario
------------------------------------
function toRewards(event)
    composer.removeScene( "src.Rewards" )
    composer.gotoScene("src.Rewards", { time = 0, params = {user = itemNU} })
    return true
end

-------------------------------------
-- Valida y guarda datos del usuario
-- @param event objeto usuario
------------------------------------
function updateUser(event)
    native.setKeyboardFocus(nil)
    lblTitleNU.alpha = 1
    transition.to( grpNewUser, { y = 0, time = 400, transition = easing.outExpo } )
    RestManager.updateUser(itemNU.id, txtName.text, txtEmail.text)
    return true
end

-------------------------------------
-- Evento Text Focus
-- @param event objeto evento
------------------------------------
function onTxtFocus(event)
    if ( "began" == event.phase ) then
        lblTitleNU.alpha = 0
        transition.to( grpNewUser, { y = -180, time = 400, transition = easing.outExpo } )
    elseif ( "submitted" == event.phase ) then
        -- Hide Keyboard
        updateUser()
    end
end

-- Called immediately on call
function scene:create( event )
    screen = self.view
    itemNU = event.params.user
    
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
    
    grpNewUser = display.newGroup()
    screen:insert(grpNewUser)
    
    lblTitleNU = display.newText({
        text = "¡Hola, bienvenido a TUKI!", 
        x = midW, y = midH - 220,
        fontSize = 40,
        font = native.systemFontBold,   
        
    })
    lblTitleNU.anchorY = 0
    lblTitleNU:setFillColor( 1 )
    grpNewUser:insert(lblTitleNU)
    
    -- Icons
    local iconUser = display.newImage( "img/usuario.png" )
    iconUser:translate( midW, midH - 100 )
    grpNewUser:insert(iconUser)
    
    local iconEmail = display.newImage( "img/email.png" )
    iconEmail:translate( midW, midH + 20 )
    grpNewUser:insert(iconEmail)
    
    -- TextFields Create
    txtName = native.newTextField( midW + 30, midH - 100, 420, 55 )
    txtName.size = 30
    txtName.hasBackground = false
    txtName.placeholder = "Nombre"
    txtName:addEventListener( "userInput", onTxtFocus )
	grpNewUser:insert(txtName)
    
    txtEmail = native.newTextField( midW + 30, midH + 20, 420, 55 )
    txtEmail.size = 30
    txtEmail.inputType = "email"
    txtEmail.hasBackground = false
    txtEmail.placeholder = "E-mail"
    txtEmail:addEventListener( "userInput", onTxtFocus )
	grpNewUser:insert(txtEmail)
    
    -- Botones
    local btnOmitirB = display.newRoundedRect( midW - 150, midH + 130, 250, 70, 10 )
    btnOmitirB:setFillColor( 1 )
    grpNewUser:insert( btnOmitirB )
    
    local btnOmitir = display.newRoundedRect( midW - 150, midH + 130, 246, 66, 10 )
    btnOmitir:setFillColor( unpack(cMarine) )
    btnOmitir:addEventListener( 'tap', toRewards) 
    btnOmitir.alpha = .8
    grpNewUser:insert( btnOmitir )
    
    local lblOmitir = display.newText({
        text = "Proporcionar en otro momento", 
        x = midW - 150, y = midH + 130,
        fontSize = 23, width = 220, align = "center",
        font = native.systemFontBold,
    })
    lblOmitir:setFillColor( 1 )
    grpNewUser:insert(lblOmitir)
    
    local btnGuardarB = display.newRoundedRect( midW + 150, midH + 130, 250, 70, 10 )
    btnGuardarB:setFillColor( 1 )
    grpNewUser:insert( btnGuardarB )
    
    local btnGuardar = display.newRoundedRect( midW + 150, midH + 130, 246, 66, 10 )
    btnGuardar:setFillColor( unpack(cMarine) )
    btnGuardar:addEventListener( 'tap', updateUser) 
    grpNewUser:insert( btnGuardar )
    
    local lblGuardar = display.newText({
        text = "Guardar", 
        x = midW + 150, y = midH + 130,
        fontSize = 30, width = 220, align = "center",
        font = native.systemFontBold,
    })
    lblGuardar:setFillColor( 1 )
    grpNewUser:insert(lblGuardar)
    
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
end

-- Hide scene
function scene:hide( event )
    if ( event.phase == "will" ) then
        if txtName then
            txtName:removeSelf()
            txtName = nil
        end
        if txtEmail then
            txtEmail:removeSelf()
            txtEmail = nil
        end
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