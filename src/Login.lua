local composer = require( "composer" )
local Sprites = require('src.Sprites')
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, loginText, grpLogin, txtSignPass, grpLoading, grpMsg
local scene = composer.newScene()

-------------------------------------
-- Nuevo Usuario
-- @param item objeto usuario
------------------------------------
function toHome()
    setLoading(false)
    backTxtPositions()
    composer.removeScene( "src.Home" )
    composer.gotoScene("src.Home", { time = 0 })
    return true
end

-------------------------------------
-- Reubicar elementos
-- @param event objeto evento
------------------------------------
function onTxtFocus(event)
    if ( "began" == event.phase ) then
        transition.to( grpLogin, { y = (-midH + 170) + h, time = 400, transition = easing.outExpo } )
    elseif ( "submitted" == event.phase ) then
        verifyKey()
    end
end

-------------------------------------
-- Reubicar a posicion original
------------------------------------
function backTxtPositions()
    -- Hide Keyboard
    native.setKeyboardFocus(nil)
    -- Interfaz Sign In
    transition.to( grpLogin, { y = 0, time = 400, transition = easing.outExpo } )
end

-------------------------------------
-- Verificar clave
-- @param event objeto evento
------------------------------------
function verifyKey(event)
    if not (txtSignPass.text == "") then
        if RestManager.networkConnection() then
            setLoading(true)
            RestManager.verifyPassword(txtSignPass.text)
        else
            showMsg("Asegurese de estar conectado a internet")
        end
    end
end

-------------------------------------
-- Muestra loading sprite
-- @param isLoading activar/desactivar
------------------------------------
function setLoading(isLoading)
    if isLoading then
        if grpLoading then
            grpLoading:removeSelf()
            grpLoading = nil
        end
        grpLoading = display.newGroup()
        screen:insert(grpLoading)

        function setDes(event)
            return true
        end
        local bg = display.newRect( midW, midH, intW, intH )
        bg:setFillColor( .85 )
        bg:addEventListener( 'tap', setDes)
        bg:setFillColor( 0 )
        bg.alpha = .3
        grpLoading:insert(bg)
        local sheet = graphics.newImageSheet(Sprites.loading.source, Sprites.loading.frames)
        local loading = display.newSprite(sheet, Sprites.loading.sequences)
        loading.x = midW
        loading.y = midH
        grpLoading:insert(loading)
        loading:setSequence("play")
        loading:play()
    else
        if grpLoading then
            grpLoading:removeSelf()
            grpLoading = nil
        end
    end
end

-------------------------------------
-- Muestra loading sprite
-- @param isLoading activar/desactivar
------------------------------------
function showMsg(message)
    setLoading(false)
    if grpMsg then
        grpMsg:removeSelf()
        grpMsg = nil
    end

    grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)

    function setDes(event)
        return true
    end
    local bg = display.newRect( midW, midH, intW, intH )
    bg:addEventListener( 'tap', setDes)
    bg:setFillColor( 0 )
    bg.alpha = .3
    grpMsg:insert(bg)

    local bg = display.newRoundedRect( midW, midH, 404, 154, 15 )
    bg:setFillColor( unpack(cTurquesa) )
    grpMsg:insert(bg)

    local bg = display.newRoundedRect( midW, midH, 400, 150, 15 )
    bg:setFillColor( unpack(cWhite) )
    grpMsg:insert(bg)

    local lblMsg = display.newText({
        text = message, 
        x = midW, y = midH, width = 380, 
        fontSize = 27, align = "center",
        font = fontSemiBold
    })
    lblMsg:setFillColor( unpack(cPurPle) )
    grpMsg:insert(lblMsg)
    
    transition.to( grpMsg, { alpha = 1, time = 400 } )
    transition.to( grpMsg, { alpha = 0, time = 400, delay = 2000 } )
end


-- Called immediately on call
function scene:create( event )
    screen = self.view
     
    local bg = display.newRect( midW, midH, intW, intH )
    bg:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } ) 
    screen:insert(bg)
    
    -- Login Elements
    grpLogin = display.newGroup()
    screen:insert(grpLogin)
    
    -- Line
    local line = display.newLine( midW - 480, midH - 220, midW + 480, midH - 220,
        midW + 480, midH + 150, midW - 480, midH + 150, midW - 480, midH - 220)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cTurquesa) )
    grpLogin:insert( line )
     
    local logoWhite = display.newImage( "img/logoWhite.png" )
    logoWhite:translate( midW - 250, midH - 20 )
    grpLogin:insert(logoWhite)
    
    -- Bg TextFields
    local bgField = display.newRoundedRect( midW + 220, midH - 80, 470, 70, 5 )
    bgField:setFillColor( unpack(cWhite) )
    grpLogin:insert( bgField )
    local bgSignPass = display.newImage("img/iconCandado.png", true) 
    bgSignPass.x = midW  + 20
    bgSignPass.y = midH - 80
    grpLogin:insert(bgSignPass)
    
    -- TextFields Sign In
    txtSignPass = native.newTextField( midW + 245, midH - 80, 400, 45 )
    txtSignPass.size = 25
    txtSignPass.isSecure = true
    txtSignPass.hasBackground = false
    txtSignPass.placeholder = "CLAVE DE ACCESO"
    txtSignPass:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtSignPass)
    
    -- Boton Canjear
    local btnAccess = display.newRoundedRect( midW + 220, midH + 30, 470, 70, 5 )
    btnAccess:setFillColor( unpack(cTurquesa) )
    grpLogin:insert( btnAccess )
    btnAccess:addEventListener( 'tap', verifyKey)

    local lblAccess = display.newText({
        text = "ENTRAR", 
        x = midW + 220, y = midH + 30, 
        fontSize = 30, width = 300,
        font = fontSemiBold, align = 'center'

    })
    lblAccess:setFillColor( unpack(cWhite) )
    grpLogin:insert(lblAccess)
    
    local lblAccess = display.newText({
        text = "www.tukicard.com", 
        x = midW, y = midH + 180, 
        fontSize = 25, width = 300,
        font = fontSemiBold, align = 'center'

    })
    lblAccess:setFillColor( unpack(cWhite) )
    grpLogin:insert(lblAccess)
    
    
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
    
end

-- Hide scene
function scene:hide( event )
    if ( event.phase == "will" ) then
        if txtSignPass then
            txtSignPass:removeSelf()
            txtSignPass = nil
        end
    end
    
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )

return scene