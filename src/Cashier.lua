local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local screen, cashierId, scrRedens, grpCashier, grpRedens, lblRTitle, lblRUser
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
-- Regresamos a Home
-- @param event objeto evento
------------------------------------
function tapCash(event)
    composer.removeScene( "src.Cash" )
    composer.gotoScene("src.Cash", { time = 400, effect = "slideLeft" })
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
    local userName = ''
    if redens[idx].reden.user then
        userName = redens[idx].reden.user
    end
    lblRUser.text = userName
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
        local bgR = display.newRoundedRect( 350, curY, 700, 140, 5 )
        bgR:setFillColor( unpack(cAqua) )
        scrRedens:insert( bgR )
        
        local bgRW = display.newRoundedRect( 350, curY, 694, 134, 5 )
        bgRW.idx = z
        bgRW:addEventListener( 'tap', tapReden)
        bgRW:setFillColor( 1 )
        scrRedens:insert( bgRW )
        
        local bgPhoto = display.newImage( "img/bgPhoto.png" )
        bgPhoto:translate(70, curY)
        bgPhoto.height = 130
        bgPhoto.width = 130
        scrRedens:insert( bgPhoto )
        
        local userName = ''
        if items[z].user then
            userName = items[z].user
        end
        local lblUser = display.newText({
            text = userName, 
            x = 340, y = curY - 35,
            fontSize = 20, width = 370, align = "left",
            font = fontRegular,   

        })
        lblUser:setFillColor( unpack(cGrayLow) )
        scrRedens:insert( lblUser )
            
        local lblDate = display.newText({
            text = items[z].dateTexto, 
            x = 470, y = curY - 35,
            fontSize = 20, width = 400, align = "right",
            font = fontRegular,   

        })
        lblDate:setFillColor( unpack(cGrayLow) )
        scrRedens:insert( lblDate )
            
        local lblTitle = display.newText({
            text = items[z].reward,
            x = 420, y = curY + 5,
            fontSize = 26, width = 530, align = "left",
            font = fontSemiBold,   

        })
        lblTitle:setFillColor( unpack(cMarine) )
        scrRedens:insert( lblTitle )
        
    end
    
    grpRedens = display.newGroup()
    grpRedens.alpha = 0
    scrRedens:insert(grpRedens)
    
    local bgToR = display.newRect( 350, 0, 694, 134 )
    bgToR:addEventListener( 'tap', tapToBlock)
    bgToR:setFillColor( unpack(cPurPle) )
    grpRedens:insert( bgToR )
    
    local bgToReden = display.newRoundedRect( 70, 0, 140, 140, 5 )
    bgToReden:setFillColor( unpack(cAqua) )
    bgToReden:addEventListener( 'tap', tapToReem)
    grpRedens:insert( bgToReden )
    
    local bgReden = display.newRoundedRect( 70, 0, 134, 134, 5 )
    bgReden:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } )
    grpRedens:insert( bgReden )
    
    local lblReden = display.newText({
        text = "REEMBOLSAR",
        x = 70, y = 0,
        fontSize = 16,
        font = fontSemiBold,   

    })
    lblReden:setFillColor( 1 )
    grpRedens:insert( lblReden )
    
    local bgToReem = display.newRoundedRect( 630, 0, 140, 140, 5 )
    bgToReem:setFillColor( unpack(cAqua) )
    bgToReem:addEventListener( 'tap', tapToReden)
    grpRedens:insert( bgToReem )
    
    local bgRedem = display.newRoundedRect( 630, 0, 134, 134, 5 )
    bgRedem:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } )
    grpRedens:insert( bgRedem )
    
    local lblRedem = display.newText({
        text = "CANJEAR",
        x = 630, y = 0,
        fontSize = 23,
        font = fontSemiBold,   

    })
    lblRedem:setFillColor( 1 )
    grpRedens:insert( lblRedem )
    
    lblRTitle = display.newText({
        text = "",
        x = 420, y = 0,
        fontSize = 26, width = 530, align = "left",
        font = fontSemiBold,    

    })
    lblRTitle:setFillColor( 1 )
    grpRedens:insert( lblRTitle )
    
    lblRUser = display.newText({
        text = "", 
        x = 340, y = -40,
        fontSize = 20, width = 370, align = "left",
        font = fontRegular,   

    })
    lblRUser:setFillColor( 1 )
    grpRedens:insert( lblRUser )
    
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
    
    grpCashier = display.newGroup()
    screen:insert(grpCashier)
    
    local btnBack = display.newImage( "img/iconPrev.png" )
    btnBack.x = midW - 450
    btnBack.y = 110
    btnBack:addEventListener( 'tap', tapReturn)
    grpCashier:insert(btnBack)
    
    local iconCash = display.newImage( "img/iconCash.png" )
    iconCash.x = midW + 440
    iconCash.y = 110
    iconCash:addEventListener( 'tap', tapCash)
    grpCashier:insert(iconCash)
    
    local lblTitle = display.newText({
        text = "RECOMPENSAS LISTAS PARA CANJEAR:", 
        x = midW, y = midH -270,
        fontSize = 28, width = 700, align = "left",
        font = fontSemiBold,   
        
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