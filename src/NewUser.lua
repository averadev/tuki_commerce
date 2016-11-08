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
    
    local bg = display.newRect( midW, midH, intW, intH )
    bg:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } ) 
    screen:insert(bg)
    
    grpNewUser = display.newGroup()
    screen:insert(grpNewUser)
    
    lblTitleNU = display.newText({
        text = "¡HOLA!, BIENVENIDO A:", 
        x = midW, y = midH - 270,
        fontSize = 50,
        font = fontSemiBold,   
        
    })
    lblTitleNU.anchorY = 0
    lblTitleNU:setFillColor( 1 )
    grpNewUser:insert(lblTitleNU)
    
    -- Line
    local line = display.newLine( midW - 480, midH - 180, midW + 480, midH - 180,
        midW + 480, midH + 180, midW - 480, midH + 180, midW - 480, midH - 180)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cTurquesa) )
    grpNewUser:insert( line )
     
    local logoWhite = display.newImage( "img/logoWhite.png" )
    logoWhite:translate( midW - 250, midH - 10 )
    grpNewUser:insert(logoWhite)
    
    -- Icons
    local btnUser1 = display.newRoundedRect( midW + 220, midH - 60, 440, 70, 5 )
    btnUser1:setFillColor( unpack(cTurquesa) )
    grpNewUser:insert( btnUser1 )
    local btnUser2 = display.newRoundedRect( midW + 220, midH - 60, 436, 66, 5 )
    btnUser2:setFillColor( unpack(cWhite) )
    grpNewUser:insert( btnUser2 )
    local iconUser = display.newImage( "img/icoUser.png" )
    iconUser:translate( midW + 40, midH - 60 )
    grpNewUser:insert(iconUser)
    
    local btnEmail1 = display.newRoundedRect( midW + 220, midH + 40, 440, 70, 5 )
    btnEmail1:setFillColor( unpack(cTurquesa) )
    grpNewUser:insert( btnEmail1 )
    local btnEmail2 = display.newRoundedRect( midW + 220, midH + 40, 436, 66, 5 )
    btnEmail2:setFillColor( unpack(cWhite) )
    grpNewUser:insert( btnEmail2 )
    local iconEmail = display.newImage( "img/icoEmail.png" )
    iconEmail:translate( midW + 40, midH + 40 )
    grpNewUser:insert(iconEmail)
    
    -- TextFields Create
    txtName = native.newTextField( midW + 240, midH - 55, 350, 55 )
    txtName.size = 26
    txtName.hasBackground = false
    txtName.placeholder = "TU NOMBRE"
    txtName:addEventListener( "userInput", onTxtFocus )
	grpNewUser:insert(txtName)
    
    txtEmail = native.newTextField( midW + 240, midH + 45, 350, 55 )
    txtEmail.size = 26
    txtEmail.inputType = "email"
    txtEmail.hasBackground = false
    txtEmail.placeholder = "TU CORREO ELECTRONICO"
    txtEmail:addEventListener( "userInput", onTxtFocus )
	grpNewUser:insert(txtEmail)
    
    -- Botones
    local btnOmitir = display.newRoundedRect( midW - 200, midH + 180, 300, 66, 10 )
    btnOmitir:setFillColor( unpack(cTurquesa) )
    btnOmitir:addEventListener( 'tap', toRewards) 
    grpNewUser:insert( btnOmitir )
    
    local lblOmitir = display.newText({
        text = "PROPORCIONAR EN OTRO MOMENTO", 
        x = midW - 200, y = midH + 180,
        fontSize = 20, width = 220, align = "center",
        font = fontSemiBold,
    })
    lblOmitir:setFillColor( unpack(cWhite) )
    grpNewUser:insert(lblOmitir)
    
    local btnGuardar = display.newRoundedRect( midW + 200, midH + 180, 300, 66, 10 )
    btnGuardar:setFillColor( unpack(cTurquesa) )
    btnGuardar:addEventListener( 'tap', updateUser) 
    grpNewUser:insert( btnGuardar )
    
    local lblGuardar = display.newText({
        text = "ENTRAR", 
        x = midW + 200, y = midH + 180,
        fontSize = 25, width = 220, align = "center",
        font = fontSemiBold,
    })
    lblGuardar:setFillColor( unpack(cWhite) )
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