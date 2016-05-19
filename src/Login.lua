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
        transition.to( loginText, { y = 65 + h, width = 224, height = 75, time = 400, transition = easing.outExpo } )
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
    transition.to( loginText, { y = midH - 200, width = 448, height = 151, time = 400, transition = easing.outExpo } )
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
    bg:setFillColor( 1 )
    grpMsg:insert(bg)

    local bg = display.newRoundedRect( midW, midH, 400, 150, 15 )
    bg:setFillColor( unpack(cMarine) )
    grpMsg:insert(bg)

    local lblMsg = display.newText({
        text = message, 
        x = midW, y = midH, width = 380, 
        fontSize = 27, align = "center",
        font = native.systemFontBold
    })
    lblMsg:setFillColor( 1 )
    grpMsg:insert(lblMsg)
    
    transition.to( grpMsg, { alpha = 1, time = 400 } )
    transition.to( grpMsg, { alpha = 0, time = 400, delay = 2000 } )
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
    
    local imgCorners = display.newImage( "img/corner.png" )
    imgCorners.anchorX = 1
    imgCorners.anchorY = 1
    imgCorners.x = intW
    imgCorners.y = intH
    screen:insert(imgCorners)
    
    loginText = display.newImage( "img/loginText.png" )
    loginText.x = midW
    loginText.y = midH - 200
    screen:insert(loginText)
    
    -- Login Elements
    grpLogin = display.newGroup()
    screen:insert(grpLogin)
    
    -- Bg TextFields
    local bgSignPass = display.newImage("img/contrasenia.png", true) 
    bgSignPass.x = midW
    bgSignPass.y = midH
    grpLogin:insert(bgSignPass)
    
    -- TextFields Sign In
    txtSignPass = native.newTextField( midW + 25, midH, 400, 55 )
    txtSignPass.size = 25
    txtSignPass.isSecure = true
    txtSignPass.hasBackground = false
    txtSignPass.placeholder = "Clave de acceso"
    txtSignPass:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtSignPass)
    
    -- Boton Canjear
    local btnAccess = display.newRoundedRect( midW + 140, midH + 100, 220, 70, 5 )
    btnAccess:setFillColor( 1 )
    grpLogin:insert( btnAccess )
    btnAccess:addEventListener( 'tap', verifyKey)

    local btnAcess2 = display.newRoundedRect( midW + 140, midH + 100, 216, 66, 5 )
    btnAcess2:setFillColor( unpack(cMarine) )
    grpLogin:insert( btnAcess2 )

    local lblAccess = display.newText({
        text = "Acceder", 
        x = midW + 140, y = midH + 100, 
        fontSize = 27,
        font = native.systemFontBold,   

    })
    lblAccess:setFillColor( 1 )
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