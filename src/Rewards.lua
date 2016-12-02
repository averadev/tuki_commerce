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
local userPoints, userId, timerRew, timeCount, lblPoints, lblTitle, grpBtnRedem
local bgLogo1, bgLogo2, imgLogo, btnRedem, lblRedemTitle, lblRedemPoints, imgReward
local rewards = {}



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
    local xtraW = 0
    if intW > 1050 then
        xtraW = (intW - 1050) / 5
    end
    
    if not(btnRedem) then
        grpRedem = display.newGroup()
        grpRedem.alpha = 0
        grpContent:insert( grpRedem )
        
        -- Detalle canje
        local bgImage = display.newRoundedRect( midW + 292, 160, 218, 163, 5 )
        bgImage:setFillColor( 1 )
        grpRedem:insert( bgImage )
        
        lblRedemTitle = display.newText({
            text = "", 
            x = midW, y = 160, 
            fontSize = 30, width = 360,
            font = fontSemiBold, align = 'left' 
        })
        lblRedemTitle.anchorY = 1
        lblRedemTitle:setFillColor( 1 )
        grpRedem:insert(lblRedemTitle)
        
        lblRedemPoints = display.newText({
            text = "", 
            x = midW, y = 180, 
            fontSize = 30, width = 360,
            font = fontBold, align = 'left' 
        })
        lblRedemPoints:setFillColor( 1 )
        grpRedem:insert(lblRedemPoints)
        
        -- Boton Canjear
        grpBtnRedem = display.newGroup()
        scrRewards:insert( grpBtnRedem )
        btnRedem = display.newRoundedRect( 690, 0, 120, 120, 5 )
        btnRedem:setFillColor( unpack(cAqua) )
        grpBtnRedem:insert(btnRedem)
        btnRedem:addEventListener( 'tap', tapRedimir)
        local bgRedem = display.newRoundedRect( 690, 0, 114, 114, 5 )
        bgRedem:setFillColor( {
            type = 'gradient',
            color1 = { unpack(cTurquesa) }, 
            color2 = { unpack(cPurPle) },
            direction = "bottom"
        } )
        grpBtnRedem:insert(bgRedem)
        local lblCanjear = display.newText({
            text = "CANJEAR", 
            x = 690, y = 0, 
            fontSize = 20,
            font = fontSemiBold,   

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
    
    if imgReward then
        imgReward:removeSelf()
        imgReward = nil
    end
    imgReward = display.newImage( item.image, system.TemporaryDirectory )
    imgReward.alpha = 0
    imgReward.height = 157
    imgReward.width = 210
    imgReward:translate(midW + 292, 160)
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
    local line = display.newLine( midW - 350, midH - 250, midW + 350, midH - 250,
        midW + 350, midH + 150, midW - 350, midH + 150, midW - 350, midH - 250)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cTurquesa) )
    grpMsg:insert( line )
    
    local lblTitle1 = display.newText({
        text = "¡GRACIAS", 
        x = midW - 20, y = midH - 170,
        fontSize = 80, width = 600,
        font = fontSemiBold, align = 'left' 
        
    })
    lblTitle1:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle1)
    local lblTitle2 = display.newText({
        text = "POR REGISTRAR TU VISITA!", 
        x = midW - 20, y = midH - 100,
        fontSize = 40, width = 600,
        font = fontSemiBold, align = 'left' 
        
    })
    lblTitle2:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle2)
    local lblTitle3 = display.newText({
        text = "GANASTE:", 
        x = midW - 20, y = midH + 20,
        fontSize = 100, width = 600,
        font = fontBold, align = 'left' 
        
    })
    lblTitle3:setFillColor( unpack(cWhite) )
    grpMsg:insert(lblTitle3)
    
    local imgBg = display.newImage( "img/circlePoints.png" )
    imgBg:translate(midW + 340, midH + 140) 
    imgBg:scale( 1.5, 1.5 )
    grpMsg:insert(imgBg)
    
    local lblTuks1 = display.newText({
        text = points, 
        x = midW + 340, y = midH + 100,
        fontSize = 100, width = 200,
        font = fontSemiBold, align = 'center'  
        
    })
    lblTuks1:setFillColor( 1 )
    grpMsg:insert(lblTuks1)
    local lblTuks2 = display.newText({
        text = 'PUNTOS', 
        x = midW + 340, y = midH + 180,
        fontSize = 40, width = 200,
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
    
    local btnBack = display.newImage( "img/iconPrev.png" )
    btnBack.x = midW - 450
    btnBack.y = 160
    btnBack:addEventListener( 'tap', tapReturn)
    grpContent:insert(btnBack)
    
    -- Line
    local line = display.newLine( midW - 300, 80, midW + 400, 80,
        midW + 400, 240, midW - 300, 240, midW - 300, 80)
    line.strokeWidth = 3
    line:setStrokeColor( unpack(cWhite) )
    grpContent:insert( line )
    
    local bgLogo = display.newImage( "img/bgLogo.png" )
    bgLogo:translate( midW - 300, 160 )
    grpContent:insert(bgLogo)
    
    local mask = graphics.newMask( "img/maskLogo.png" )
    local imgLogo = display.newImage( logoCom, system.TemporaryDirectory )
    imgLogo:setMask( mask )
    imgLogo:translate( midW - 300, 160 )
    imgLogo.width = 180
    imgLogo.height = 180
    grpContent:insert(imgLogo)
    
    
    grpTitle = display.newGroup()
    grpContent:insert( grpTitle )
    
    local lblPoints = display.newText({
        text = userPoints, 
        x = midW + 100, y = 120,
        fontSize = 80, width = 500,
        font = fontBold, align = 'right'
    })
    lblPoints:setFillColor( unpack(cWhite) )
    grpTitle:insert(lblPoints)
    
    local lblTitle = display.newText({
        text = "PUNTOS DISPONIBLES", 
        x = midW + 100, y = 180,
        fontSize = 40, width = 500,
        font = fontSemiBold, align = 'right'
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( unpack(cWhite) )
    grpTitle:insert(lblTitle)
    
    scrRewards = widget.newScrollView
	{
        top = 280,
		width = 750,
		height = intH - 320,
		horizontalScrollDisabled = true,
        hideBackground = true
	}
    scrRewards.x = midW + 25
	grpContent:insert(scrRewards)
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
        scrRewards:insert( bgR )
        
        rewards[z].bgDesc = display.newRoundedRect( 375, curY, 740, 110, 5 )
        rewards[z].bgDesc:setFillColor( 1 )
        scrRewards:insert( rewards[z].bgDesc )
        
        local bgPoints0 = display.newRoundedRect( 0, curY, 130, 120, 5 )
        bgPoints0.anchorX = 0
        bgPoints0:setFillColor( unpack(cAqua) )
        scrRewards:insert( bgPoints0 )
        
        local bgPoints = display.newRoundedRect( 3, curY, 124, 114, 5 )
        bgPoints.anchorX = 0
        bgPoints:setFillColor( {
            type = 'gradient',
            color1 = { unpack(cTurquesa) }, 
            color2 = { unpack(cPurPle) },
            direction = "bottom"
        } )
        scrRewards:insert( bgPoints )
        
        rewards[z].lblTitle = display.newText({
            text = items[z].name, 
            x = 390, y = curY - 25,
            fontSize = 24, width = 480, align = "left",
            font = fontSemiBold,   

        })
        rewards[z].lblTitle:setFillColor( unpack(cMarine) )
        scrRewards:insert( rewards[z].lblTitle )
        
        rewards[z].lblDesc = display.newText({
            text = items[z].description, 
            x = 390, y = curY + 15, height = 45,
            fontSize = 20, width = 480, align = "left",
            font = fontSemiRegular,   

        })
        rewards[z].lblDesc:setFillColor( unpack(cGrayLow) )
        scrRewards:insert( rewards[z].lblDesc )
        
        local lblPoints = display.newText({
            text = items[z].points, 
            x = 65, y = curY - 25, fontSize = 60,
            font = fontSemiBold 

        })
        lblPoints:setFillColor( 1 )
        scrRewards:insert( lblPoints )
        
        local lblPointsB = display.newText({
            text = "PUNTOS", 
            x = 65, y = curY + 25, fontSize = 24,
            font = fontSemiBold 

        })
        lblPointsB:setFillColor( 1 )
        scrRewards:insert( lblPointsB )
        
        if rewards[z].lblTitle.height > 35 then
            rewards[z].lblTitle.y = curY - 20
            rewards[z].lblDesc.y = curY + 28
        end
        
        if tonumber(userPoints) < tonumber(items[z].points) then
            local bgDisabled = display.newRoundedRect( 375, curY, 750, 120, 5 )
            bgDisabled:setFillColor( 0 )
            bgDisabled.alpha = .4
            scrRewards:insert( bgDisabled )
        else
            bgR.idx = z
            bgR:addEventListener( 'tap', tapReward)
        end
        
    end
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