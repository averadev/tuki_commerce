local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local screen, cashierId, scrRedens, grpCashier, grpRedens, lblRTitle
local redens = {}



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
-- Seleccion redencion
-- @param event objeto evento
------------------------------------
function tapToReden(event)
    showMsg("msgToRedem")
    -- Hacer valida la redencion
    RestManager.setRedemption(2, grpRedens.reden.id, cashierId, grpRedens.reden.points)
    return true
end

-------------------------------------
-- Seleccion redencion
-- @param event objeto evento
------------------------------------
function tapToReem(event)
    showMsg("msgToReem")
    -- Hacer invalida la redencion
    RestManager.setRedemption(3, grpRedens.reden.id, cashierId, grpRedens.reden.points)
    return true
end

-------------------------------------
-- Muestra el mensaje
-- @param msg objeto evento
------------------------------------
function showMsg(msg)
    local grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/"..msg..".png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    transition.to( grpMsg, { alpha = 1, time = 700 })
    transition.to( grpCashier, { alpha = 0, time = 500, onComplete = function() 
        audio.play( fxCash )   
    end })
    timer.performWithDelay( 4000, tapReturn )
    
    
    return true
end

-------------------------------------
-- Seleccion redencion
-- @param event objeto evento
------------------------------------
function tapToBlock(event)
    return true
end

-------------------------------------
-- Seleccion redencion
-- @param event objeto evento
------------------------------------
function tapReden(event)
    audio.play( fxTap )
    local idx = event.target.idx
    grpRedens.alpha = 1
    grpRedens.y = event.target.y
    grpRedens.reden = redens[idx].reden
    lblRTitle.text = redens[idx].reden.reward
    return true
end

-------------------------------------
-- Mostrar redenciones
-- @param event objeto evento
------------------------------------
function showRedenciones(items)
    for z = 1, #items, 1 do 
        local curY = (z*155) - 80
        
        redens[z] = {}
        redens[z].reden = items[z]
        local bgR = display.newRoundedRect( 350, curY, 700, 140, 10 )
        bgR:setFillColor( unpack(cAqua) )
        scrRedens:insert( bgR )
        
        local bgRW = display.newRoundedRect( 350, curY, 680, 120, 10 )
        bgRW.idx = z
        bgRW:addEventListener( 'tap', tapReden)
        bgRW:setFillColor( 1 )
        scrRedens:insert( bgRW )
        
        local bgPhoto = display.newImage( "img/bgPhoto.png" )
        bgPhoto:translate(70, curY)
        scrRedens:insert( bgPhoto )
        
        local userName = ''
        if items[z].user then
            userName = items[z].user
        end
        local lblUser = display.newText({
            text = userName, 
            x = 343, y = curY - 35,
            fontSize = 20, width = 400, align = "left",
            font = native.systemFont,   

        })
        lblUser:setFillColor( unpack(cGrayLow) )
        scrRedens:insert( lblUser )
            
        local lblDate = display.newText({
            text = items[z].dateTexto, 
            x = 470, y = curY - 35,
            fontSize = 20, width = 400, align = "right",
            font = native.systemFont,   

        })
        lblDate:setFillColor( unpack(cGrayLow) )
        scrRedens:insert( lblDate )
            
        local lblTitle = display.newText({
            text = items[z].reward,
            x = 410, y = curY + 5,
            fontSize = 26, width = 530, align = "left",
            font = native.systemFontBold,   

        })
        lblTitle:setFillColor( unpack(cMarine) )
        scrRedens:insert( lblTitle )
        
    end
    
    grpRedens = display.newGroup()
    grpRedens.alpha = 0
    scrRedens:insert(grpRedens)
    
    local bgToR = display.newRect( 350, 0, 680, 120 )
    bgToR:addEventListener( 'tap', tapToBlock)
    bgToR:setFillColor( unpack(cMarine) )
    grpRedens:insert( bgToR )
    
    local bgToReem = display.newRect( 90, 0, 160, 120 )
    bgToReem:addEventListener( 'tap', tapToReem)
    bgToReem:setFillColor( unpack(cMarine) )
    grpRedens:insert( bgToReem )
    
    local bgToRedem = display.newRect( 610, 0, 160, 120 )
    bgToRedem:addEventListener( 'tap', tapToReden)
    bgToRedem:setFillColor( unpack(cMarine) )
    grpRedens:insert( bgToRedem )
    
    local bgToReden = display.newImage( "img/toReden.png" )
    bgToReden.x = 350
    grpRedens:insert(bgToReden)
    
    lblRTitle = display.newText({
        text = "",
        x = 350, y = 0,
        fontSize = 28, width = 280,
        font = native.systemFontBold,   

    })
    lblRTitle:setFillColor( 1 )
    grpRedens:insert( lblRTitle )
    
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
    
    grpCashier = display.newGroup()
    --grpCashier.alpha = 0
    screen:insert(grpCashier)
    
    local btnBack = display.newImage( "img/btnBack.png" )
    btnBack.x = 170
    btnBack.y = 80
    btnBack:addEventListener( 'tap', tapReturn)
    grpCashier:insert(btnBack)
    
    local lblTitle = display.newText({
        text = "RECOMPENSAS LISTAS PARA CANJEAR:", 
        x = midW, y = midH -255,
        fontSize = 28, width = 700, align = "left",
        font = native.systemFontBold,   
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( 1 )
    grpCashier:insert(lblTitle)
    
    scrRedens = widget.newScrollView
	{
		width = 700,
		height = 550,
		horizontalScrollDisabled = true,
        hideBackground = true
	}
    scrRedens.x = midW
    scrRedens.y = midH + 60
	grpCashier:insert(scrRedens)
    
    --Obtener redenciones
    cashierId = event.params.user.id
    RestManager.getRedenciones()
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