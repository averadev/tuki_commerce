local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
local fxMetronome = audio.loadSound( "fx/metronome.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, scrRewards, grpMsg, grpContent, grpRedem, grpTitle
local scene = composer.newScene()
local userPoints, userId, timerRew, timeCount, lblPoints, lblTitle, grpBtnRedem, grpRew
local bgLogo1, bgLogo2, imgLogo, btnRedem, lblRedemTitle, lblRedemPoints, imgReward, contHeader
local bgScr, btnBack
local scrRH = 0
local xtraScr = 0
local rewards = {}


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
        btnBack.x = midW - 420
        btnBack.y = 160
        contHeader.x = midW
        contHeader.y = 160
        scrRewards.height = intH - 320
        scrRewards.y = 280
        scrRewards.x = midW + 25
        grpRew.y = 0
        scrRewards:setScrollHeight( scrRH )
        if grpBtnRedem then
            grpBtnRedem.y = grpBtnRedem.y + (xtraScr / 2)
        end
        xtraScr = 0
    else
        btnBack.x = 30
        btnBack.y = 70
        contHeader.x = midW - 25
        contHeader.y = 200
        scrRewards.x = midW
        scrRewards.y = 320
        xtraScr = (intH - 380) - scrRewards.height
        scrRewards.height = intH - 380
        grpRew.y = (xtraScr / 2) * -1
        scrRewards:setScrollHeight( scrRH - xtraScr )
        if grpBtnRedem then
            grpBtnRedem.y = grpBtnRedem.y - (xtraScr / 2)
        end
    end
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
-- Cance Time
-- @param event objeto evento
------------------------------------
function cancelTime(event)
    timeCount = timeCount + 1
    if timeCount == 5 then
        tapReturn()
    else
        audio.play(fxMetronome)
        timerRew = timer.performWithDelay( 1000, cancelTime, 1 )
    end
    return true
end

-------------------------------------
-- Redimir Recompensa
-- @param event objeto evento
------------------------------------
function tapRedimir(event)
    btnRedem:removeEventListener( 'tap', tapRedimir)
    if grpMsg then
        grpMsg:removeSelf()
        grpMsg = nil
    end
    grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/redemReward.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    transition.to( grpMsg, { alpha = 1, time = 700 })
    transition.to( grpContent, { alpha = 0, time = 500, onComplete = function() 
        audio.play( fxCash )   
    end })
    timer.performWithDelay( 4000, tapReturn )
    
    -- Descontar puntos
    RestManager.insertRedemption(userId,  btnRedem.reward.id, btnRedem.reward.points)
    return true
end

-------------------------------------
-- Seleccionar Tap
-- @param event objeto evento
------------------------------------
function tapReward(event)
    -- Index Reward
    local idx = event.target.idx
    
    -- Verify is not selected
    if not(rewards[idx].selected) then
        -- Unselect rewards
        for z = 1, #rewards, 1 do 
            if rewards[z].selected then
                
                rewards[z].selected = false
                rewards[z].bgDesc:setFillColor( 1 )
                rewards[z].lblTitle:setFillColor( unpack(cMarine) )
                rewards[z].lblDesc:setFillColor( unpack(cGrayLow) )
            end
        end
        -- Select reward
        audio.play( fxTap )
        rewards[idx].selected = true
        rewards[idx].bgDesc:setFillColor( unpack(cPurPle) )
        rewards[idx].lblTitle:setFillColor( 1 )
        rewards[idx].lblDesc:setFillColor( 1 )
        -- Show Reward
        showReward(rewards[idx].reward, event.target.y)
    end
    return true
end

-------------------------------------
-- Mostrar recompensa
-- @param event objeto evento
------------------------------------
function showReward(item, posY)
    if not(btnRedem) then
        grpRedem = display.newGroup()
        grpRedem.alpha = 0
        contHeader:insert( grpRedem )
        
        -- Detalle canje
        local bgImage = display.newRoundedRect( 292, 0, 218, 163, 5 )
        bgImage:setFillColor( 1 )
        grpRedem:insert( bgImage )
        
        lblRedemTitle = display.newText({
            text = "", 
            x = 0, y = 0, 
            fontSize = 28, width = 300,
            font = fontSemiBold, align = 'left' 
        })
        lblRedemTitle.anchorY = 1
        lblRedemTitle:setFillColor( 1 )
        grpRedem:insert(lblRedemTitle)
        
        lblRedemPoints = display.newText({
            text = "", 
            x = 0, y = 20, 
            fontSize = 28, width = 300,
            font = fontBold, align = 'left' 
        })
        lblRedemPoints:setFillColor( 1 )
        grpRedem:insert(lblRedemPoints)
        
        -- Boton Canjear
        grpBtnRedem = display.newContainer( 120, 120 )
        grpBtnRedem.x = 690
        grpBtnRedem.y = 0
        scrRewards:insert( grpBtnRedem )
        btnRedem = display.newRoundedRect( 0, 0, 120, 120, 5 )
        btnRedem:setFillColor( unpack(cAqua) )
        grpBtnRedem:insert(btnRedem)
        btnRedem:addEventListener( 'tap', tapRedimir)
        local bgRedem = display.newRoundedRect( 0, 0, 114, 114, 5 )
        bgRedem:setFillColor( {
            type = 'gradient',
            color1 = { unpack(cTurquesa) }, 
            color2 = { unpack(cPurPle) },
            direction = "bottom"
        } )
        grpBtnRedem:insert(bgRedem)
        local lblCanjear = display.newText({
            text = "CANJEAR", 
            x = 0, y = 0, 
            fontSize = 20,
            font = fontSemiBold
        })
        lblCanjear:setFillColor( 1 )
        grpBtnRedem:insert(lblCanjear)
        
        -- Animaciones
        transition.to( grpTitle, { time = 500, alpha = 0 })
        transition.to( grpRedem, { time = 500, delay = 500, alpha = 1 })
        transition.to( bgLogo1, { time = 500, width = 320, y = 270, height = 245 })
        transition.to( bgLogo2, { time = 500, width = 300, y = 270, height = 225 })
        
    end
    
    grpBtnRedem.y = posY
    if xtraScr > 0 then
        grpBtnRedem.y = posY - (xtraScr / 2)
    end
    
    if imgReward then
        imgReward:removeSelf()
        imgReward = nil
    end
    imgReward = display.newImage( item.image, system.TemporaryDirectory )
    imgReward.alpha = 0
    imgReward.height = 157
    imgReward.width = 210
    imgReward:translate(292, 0)
    grpRedem:insert(imgReward)
    transition.to( imgReward, { time = 1000, alpha = 1 })
    
    btnRedem.reward = item
    lblRedemTitle.text = item.name
    lblRedemPoints.text = item.points.." PUNTOS"
end

-------------------------------------
-- Mensaje de puntos
-- @param points puntos a mostrar
------------------------------------
function showPoints(points)
    grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    -- Line
    local line = display.newLine( midW - 350, midH - 250, midW + 280, midH - 250,
        midW + 280, midH + 150, midW - 350, midH + 150, midW - 350, midH - 250)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cTurquesa) )
    grpMsg:insert( line )
    
    local lblTitle1 = display.newText({
        text = "¡GRACIAS", 
        x = midW - 50, y = midH - 170,
        fontSize = 70, width = 500,
        font = fontSemiBold, align = 'left' 
        
    })
    lblTitle1:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle1)
    local lblTitle2 = display.newText({
        text = "POR REGISTRAR TU VISITA!", 
        x = midW - 50, y = midH - 100,
        fontSize = 35, width = 500,
        font = fontSemiBold, align = 'left' 
        
    })
    lblTitle2:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle2)
    local lblTitle3 = display.newText({
        text = "GANASTE:", 
        x = midW - 50, y = midH + 20,
        fontSize = 90, width = 500,
        font = fontBold, align = 'left' 
        
    })
    lblTitle3:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle3)
    
    local imgBg = display.newImage( "img/circlePoints.png" )
    imgBg:translate(midW + 260, midH + 140) 
    imgBg:scale( 1.2, 1.2 )
    grpMsg:insert(imgBg)
    
    local lblTuks1 = display.newText({
        text = points, 
        x = midW + 260, y = midH + 110,
        fontSize = 90, width = 200,
        font = fontSemiBold, align = 'center'  
        
    })
    lblTuks1:setFillColor( 1 )
    grpMsg:insert(lblTuks1)
    local lblTuks2 = display.newText({
        text = 'PUNTOS', 
        x = midW + 260, y = midH + 175,
        fontSize = 35, width = 200,
        font = fontSemiBold, align = 'center'  
        
    })
    lblTuks2:setFillColor( 1 )
    grpMsg:insert(lblTuks2)
    
    transition.to( grpMsg, { alpha = 1, time = 1000 })
    audio.play( fxCash )
    transition.to( grpMsg, { alpha = 0, time = 500, delay = 3500 })
    transition.to( grpContent, { alpha = 1, time = 500, delay = 3500 })
end

-------------------------------------
-- Mostramos pantalla
------------------------------------
function showList()
    
    grpContent = display.newGroup()
    grpContent.alpha = 0
    screen:insert(grpContent)
    
    btnBack = display.newImage( "img/iconPrev.png" )
    btnBack.x = midW - 420
    btnBack.y = 160
    btnBack:addEventListener( 'tap', tapReturn)
    grpContent:insert(btnBack)
    
    contHeader = display.newContainer( 820, 300 )
    contHeader.x = midW
    contHeader.y = 160
    grpContent:insert( contHeader )
    if position == 'portrait' or position == 'portraitUpsideDown' then
        contHeader.x = midW - 25
        contHeader.y = 200
    end
    
    -- Line
    local line = display.newLine( -300, -80, 400, -80,
         400, 80, -300, 80, -300, -80)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cWhite) )
    contHeader:insert( line )
    
    local bgLogo = display.newImage( "img/bgLogo.png" )
    bgLogo:translate( -260, 0 )
    contHeader:insert(bgLogo)
    
    local mask = graphics.newMask( "img/maskLogo.png" )
    local imgLogo = display.newImage( logoCom, system.TemporaryDirectory )
    imgLogo:setMask( mask )
    imgLogo:translate( -260, 0 )
    imgLogo.width = 180
    imgLogo.height = 180
    contHeader:insert(imgLogo)
    
    grpTitle = display.newGroup()
    contHeader:insert( grpTitle )
    
    local lblPoints = display.newText({
        text = userPoints, 
        x = 100, y = -40,
        fontSize = 80, width = 500,
        font = fontBold, align = 'right'
    })
    lblPoints:setFillColor( unpack(cWhite) )
    grpTitle:insert(lblPoints)
    
    local lblTitle = display.newText({
        text = "PUNTOS DISPONIBLES", 
        x = 100, y = 20,
        fontSize = 40, width = 500,
        font = fontSemiBold, align = 'right'
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( unpack(cWhite) )
    grpTitle:insert(lblTitle)
    
    scrRewards = widget.newScrollView
	{
        width = 750,
		height = 448,
		horizontalScrollDisabled = true,
        hideBackground = true
	}
    scrRewards.anchorY = 0
    scrRewards.y = 280
    scrRewards.x = midW + 25
	grpContent:insert(scrRewards)
    
    grpRew = display.newGroup()
    grpRew.anchorY = 0
    scrRewards:insert( grpRew )
    
    RestManager.getRewards()
end

-------------------------------------
-- Mostramos recompensas
-- @param items lista de recompensas
------------------------------------
function showRewards(items)
    for z = 1, #items, 1 do 
        local curY = (z*140) - 70
        
        rewards[z] = {}
        rewards[z].reward = items[z]
        local bgR = display.newRoundedRect( 375, curY, 750, 120, 5 )
        bgR:setFillColor( unpack(cAqua) )
        grpRew:insert( bgR )
        
        rewards[z].bgDesc = display.newRoundedRect( 375, curY, 740, 110, 5 )
        rewards[z].bgDesc:setFillColor( 1 )
        grpRew:insert( rewards[z].bgDesc )
        
        local bgPoints0 = display.newRoundedRect( 0, curY, 130, 120, 5 )
        bgPoints0.anchorX = 0
        bgPoints0:setFillColor( unpack(cAqua) )
        grpRew:insert( bgPoints0 )
        
        local bgPoints = display.newRoundedRect( 3, curY, 124, 114, 5 )
        bgPoints.anchorX = 0
        bgPoints:setFillColor( {
            type = 'gradient',
            color1 = { unpack(cTurquesa) }, 
            color2 = { unpack(cPurPle) },
            direction = "bottom"
        } )
        grpRew:insert( bgPoints )
        
        rewards[z].lblTitle = display.newText({
            text = items[z].name, 
            x = 390, y = curY - 25,
            fontSize = 24, width = 480, align = "left",
            font = fontSemiBold,   

        })
        rewards[z].lblTitle:setFillColor( unpack(cMarine) )
        grpRew:insert( rewards[z].lblTitle )
        
        rewards[z].lblDesc = display.newText({
            text = items[z].description, 
            x = 390, y = curY + 15, height = 45,
            fontSize = 20, width = 480, align = "left",
            font = fontSemiRegular,   

        })
        rewards[z].lblDesc:setFillColor( unpack(cGrayLow) )
        grpRew:insert( rewards[z].lblDesc )
        
        local lblPoints = display.newText({
            text = items[z].points, 
            x = 65, y = curY - 25, fontSize = 60,
            font = fontSemiBold 

        })
        lblPoints:setFillColor( 1 )
        grpRew:insert( lblPoints )
        
        local lblPointsB = display.newText({
            text = "PUNTOS", 
            x = 65, y = curY + 25, fontSize = 24,
            font = fontSemiBold 

        })
        lblPointsB:setFillColor( 1 )
        grpRew:insert( lblPointsB )
        
        if rewards[z].lblTitle.height > 35 then
            rewards[z].lblTitle.y = curY - 20
            rewards[z].lblDesc.y = curY + 28
        end
        
        if tonumber(userPoints) < tonumber(items[z].points) then
            local bgDisabled = display.newRoundedRect( 375, curY, 750, 120, 5 )
            bgDisabled:setFillColor( 0 )
            bgDisabled.alpha = .4
            grpRew:insert( bgDisabled )
        else
            bgR.idx = z
            bgR:addEventListener( 'tap', tapReward)
        end
    end
    scrRH = #items * 140
    scrRewards:setScrollHeight( scrRH )
    rotateScr()
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
    bgScr.anchorX = 0
    bgScr.anchorY = 0
    screen:insert(bgScr)
    
    userId = event.params.user.id
    userPoints = event.params.user.points
    showList()
    if event.params.user.newPoints > 0 then
        showPoints(event.params.user.newPoints)
    else
        transition.to( grpContent, { alpha = 1, time = 1000 })
    end
    -- Timer
    timeCount = 0
    --timerRew = timer.performWithDelay( 25000, cancelTime, 1 )
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
end

-- Hide scene
function scene:hide( event )
    if ( event.phase == "will" ) then
        if timerRew then
            timer.cancel(timerRew)
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