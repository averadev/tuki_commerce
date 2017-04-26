local composer = require( "composer" )
local widget = require( "widget" )
local Sprites = require('src.Sprites')
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local screen, cashierId, scrRedens, grpCashier, grpRedens, lblRTitle, lblRUser
local bgScr, lblTitle, lblTitle2, bgCheck, iconCheck, btnBack, iconCash, grpLstRen, grpMultiReden
local scrRH = 0
local noMulti = 0
local redens = {}
local doMark = {}


-------------------------------------
-- Rotate screen
-- @param item objeto usuario
------------------------------------
function rotateScr()
    intW = display.contentWidth
    intH = display.contentHeight
    midW = intW / 2
    midH = intH / 2
    bgScr.width = intW
    bgScr.height = intH
    
    -- Change positions
    if position == 'landscapeLeft' or position == 'landscapeRight' then
        btnBack.x = midW - 450
        btnBack.y = 110
        iconCash.x = midW + 440
        iconCash.y = 110
        lblTitle.x = midW
        lblTitle.y = midH - 320
        bgCheck.x = midW - 150
        bgCheck.y = midH - 255
        iconCheck.x = midW - 325
        iconCheck.y = midH - 255
        lblTitle2.x = midW + 50
        lblTitle2.y = midH - 265
        scrRedens.x = midW
        scrRedens.y = 170
        grpLstRen.y = 0
        scrRedens.height = 550
        scrRedens:setScrollHeight( scrRH )
    else
        btnBack.x = 50
        btnBack.y = 90
        iconCash.x = intW - 50
        iconCash.y = 90
        lblTitle.x = midW
        lblTitle.y = 150
        scrRedens.x = midW
        scrRedens.y = 200
        xtraScr = (intH - 250) - scrRedens.height
        scrRedens.height = intH - 250
        grpLstRen.y = (xtraScr / 2) * -1
        scrRedens:setScrollHeight( scrRH - xtraScr )
    end
end

-------------------------------------
-- Regresamos a Home
-- @param event objeto evento
------------------------------------
function tapGoCheck(event)
    audio.play( fxTap )
    local t = event.target
    if t.isCheck then
        t.isCheck = false
        iconCheck:setSequence("uncheck")
        grpMultiReden.alpha = 0
        for z = 1, #doMark, 1 do
            doMark[z].alpha = 0
        end
    else
        noMulti = 0
        t.isCheck = true
        iconCheck:setSequence("check")
        grpRedens.alpha = 0
    end
    return true
end

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
-- Multiseleccion redencion
-- @param event objeto evento
------------------------------------
function tapMultiReden(event)
    showMsg("msgToRedem")
    local ids = ''
    for z = 1, #doMark, 1 do
        if doMark[z].alpha == 1 then
            if z == 1 then
                ids = doMark[z].id
            else
                ids = ids..'-'..doMark[z].id
            end    
        end    
    end
    RestManager.setMultiRedemption(ids, cashierId)
    return true
end

-------------------------------------
-- Seleccion redencion
-- @param event objeto evento
------------------------------------
function tapToReden(event)
    showMsg("msgToRedem")
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
    if bgCheck.isCheck then
        -- Multiselector
        if grpRedens.alpha == 1 then
            grpRedens.alpha = 0
        end
        if doMark[idx].alpha == 1 then
            noMulti = noMulti - 1
            doMark[idx].alpha = 0
            if noMulti == 0 then grpMultiReden.alpha = 0 end 
        else
            noMulti = noMulti + 1
            grpMultiReden.alpha = 1
            doMark[idx].alpha = 1
        end
    else
        -- One selector
        grpRedens.alpha = 1
        grpRedens.y = event.target.y
        grpRedens.reden = redens[idx].reden
        lblRTitle.text = redens[idx].reden.reward
        local userName = ''
        if redens[idx].reden.user then
            userName = redens[idx].reden.user
        end
        lblRUser.text = userName
    end
    return true
end

-------------------------------------
-- Mostrar redenciones
-- @param event objeto evento
------------------------------------
function showRedenciones(data)
    -- Mostramos pago por consumo
    if data.schema == '2' then
        iconCash.alpha = 1
    end
    -- Mostramos redenciones por cerrar
    local items = data.items
    for z = 1, #items, 1 do 
        local curY = (z*155) - 80
        
        redens[z] = {}
        redens[z].reden = items[z]
        local bgR = display.newRoundedRect( 350, curY, 700, 140, 5 )
        bgR:setFillColor( unpack(cAqua) )
        grpLstRen:insert( bgR )
        
        local bgRW = display.newRoundedRect( 350, curY, 694, 134, 5 )
        bgRW.idx = z
        bgRW:addEventListener( 'tap', tapReden)
        bgRW:setFillColor( 1 )
        grpLstRen:insert( bgRW )
        
        local bgPhoto = display.newImage( "img/bgPhoto.png" )
        bgPhoto:translate(70, curY)
        bgPhoto.height = 130
        bgPhoto.width = 130
        grpLstRen:insert( bgPhoto )
        
        -- Mostramos foto de perfil
        if items[z].fbid then
            if not (items[z].fbid == '') then
                local fbImg = display.newContainer( 130, 130 )
                fbImg.x = 70
                fbImg.y = curY
                grpLstRen:insert( fbImg )
                RestManager.getFBImages(items[z].fbid, fbImg)
            end
        end
        
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
        grpLstRen:insert( lblUser )
            
        local lblDate = display.newText({
            text = items[z].dateTexto, 
            x = 470, y = curY - 35,
            fontSize = 20, width = 400, align = "right",
            font = fontRegular,   

        })
        lblDate:setFillColor( unpack(cGrayLow) )
        grpLstRen:insert( lblDate )
            
        local lblReward = display.newText({
            text = items[z].reward,
            x = 420, y = curY + 5,
            fontSize = 26, width = 530, align = "left",
            font = fontSemiBold,   

        })
        lblReward:setFillColor( unpack(cMarine) )
        grpLstRen:insert( lblReward )
                
        doMark[z] = display.newImage( "img/doMark.png" )
        doMark[z].id = items[z].id
        doMark[z].alpha = 0
        doMark[z]:translate(665, curY - 35)
        grpLstRen:insert( doMark[z] )
        
    end
    scrRH = #items * 155
    scrRedens:setScrollHeight( scrRH )
    
    grpRedens = display.newGroup()
    grpRedens.alpha = 0
    grpLstRen:insert(grpRedens)
    
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
    
    bgScr = display.newRect( 0, 0, intW, intH )
    bgScr:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } ) 
    bgScr.anchorY = 0
    bgScr.anchorX = 0
    screen:insert(bgScr)
    
    grpCashier = display.newGroup()
    screen:insert(grpCashier)
    
    btnBack = display.newImage( "img/iconPrev.png" )
    btnBack.x = midW - 450
    btnBack.y = 110
    btnBack:addEventListener( 'tap', tapReturn)
    grpCashier:insert(btnBack)
    
    iconCash = display.newImage( "img/iconCash.png" )
    iconCash.x = midW + 440
    iconCash.y = 110
    iconCash.alpha = 0
    iconCash:addEventListener( 'tap', tapCash)
    grpCashier:insert(iconCash)
    
    lblTitle = display.newText({
        text = "RECOMPENSAS LISTAS PARA CANJEAR:", 
        x = midW, y = midH - 320,
        fontSize = 28, width = 700, align = "left",
        font = fontSemiBold,   
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( 1 )
    grpCashier:insert(lblTitle)
    
    bgCheck = display.newRect( midW - 150, midH - 255, 400, 50 )
    bgCheck.alpha = .01
    bgCheck.isCheck = false
    bgCheck:addEventListener( 'tap', tapGoCheck)
    screen:insert(bgCheck)
    
    local sheet = graphics.newImageSheet(Sprites.iconCheck.source, Sprites.iconCheck.frames)
    iconCheck = display.newSprite(sheet, Sprites.iconCheck.sequences)
    iconCheck.x = midW - 30
    iconCheck.y = midH - 270
    grpCashier:insert(iconCheck)
    
    lblTitle2 = display.newText({
        text = "MARCAR VARIAS COMO CANJEADAS", 
        x = midW + 50, y = midH - 270,
        fontSize = 20, width = 700, align = "left",
        font = fontSemiBold,   
        
    })
    lblTitle2.anchorY = 0
    grpCashier:insert(lblTitle2)
    
    grpMultiReden = display.newContainer( 140, 180 )
    grpMultiReden.alpha = 0
    grpMultiReden:translate( midW + 280, midH - 260 )
    grpCashier:insert(grpMultiReden)
    
    local bgToReden = display.newRoundedRect( 0, 0, 140, 80, 5 )
    bgToReden:setFillColor( unpack(cAqua) )
    bgToReden:addEventListener( 'tap', tapMultiReden)
    grpMultiReden:insert( bgToReden )
    
    local bgReden = display.newRoundedRect( 0, 0, 134, 74, 5 )
    bgReden:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cTurquesa) }, 
        color2 = { unpack(cPurPle) },
        direction = "bottom"
    } )
    grpMultiReden:insert( bgReden )
    
    local lblReden = display.newText({
        text = "CANJEAR",
        x = 0, y = 0,
        fontSize = 20,
        font = fontSemiBold,   

    })
    lblReden:setFillColor( 1 )
    grpMultiReden:insert( lblReden )
    
    scrRedens = widget.newScrollView
	{
		width = 700,
		height = 550,
		horizontalScrollDisabled = true,
        hideBackground = true
	}
    scrRedens.anchorY = 0
    scrRedens.x = midW
    scrRedens.y = 170
	grpCashier:insert(scrRedens)
    
    grpLstRen = display.newGroup()
    grpLstRen.anchorY = 0
	scrRedens:insert(grpLstRen)
    
    --Obtener redenciones
    cashierId = event.params.user.id
    RestManager.getRedenciones()
    rotateScr()
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