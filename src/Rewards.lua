local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local screen, scrRewards, grpMsg, grpContent, grpRedem
local scene = composer.newScene()
local userPoints, userId
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
                rewards[z].bgDescR:setFillColor( 1 )
                rewards[z].lblTitle:setFillColor( unpack(cMarine) )
                rewards[z].lblDesc:setFillColor( unpack(cGrayLow) )
            end
        end
        -- Select reward
        audio.play( fxTap )
        rewards[idx].selected = true
        rewards[idx].bgDesc:setFillColor( unpack(cMarine) )
        rewards[idx].bgDescR:setFillColor( unpack(cMarine) )
        rewards[idx].lblTitle:setFillColor( 1 )
        rewards[idx].lblDesc:setFillColor( 1 )
        -- Show Reward
        showReward(rewards[idx].reward)
    end
    return true
end

-------------------------------------
-- Mostrar recompensa
-- @param event objeto evento
------------------------------------
function showReward(item)
    if not(btnRedem) then
        grpRedem = display.newGroup()
        grpRedem.alpha = 0
        grpContent:insert( grpRedem )
        
        -- Detalle canje
        local bgDetail = display.newRect( midW - 335, 350, 300, 64 )
        bgDetail.alpha = .5
        bgDetail:setFillColor( 0 )
        grpRedem:insert( bgDetail )
        
        lblRedemTitle = display.newText({
            text = "", 
            x = midW - 300, y = 350, 
            fontSize = 18, width = 220,
            font = native.systemFontBold,   

        })
        lblRedemTitle:setFillColor( 1 )
        grpRedem:insert(lblRedemTitle)
        
        
        local bgPoints = display.newRect( midW - 450, 350, 70, 64 )
        bgPoints.alpha = .5
        bgPoints:setFillColor( unpack(cMarine) )
        grpRedem:insert( bgPoints )
        
        lblRedemPoints = display.newText({
            text = "", 
            x = midW - 450, y = 350, 
            fontSize = 30,
            font = native.systemFontBold,   

        })
        lblRedemPoints:setFillColor( 1 )
        grpRedem:insert(lblRedemPoints)
        
        -- Boton Canjear
        btnRedem = display.newRoundedRect( midW - 335, 435, 320, 70, 5 )
        btnRedem:setFillColor( 1 )
        grpRedem:insert( btnRedem )
        btnRedem:addEventListener( 'tap', tapRedimir)
        
        local btnRedem2 = display.newRoundedRect( midW - 335, 435, 316, 66, 5 )
        btnRedem2:setFillColor( unpack(cMarine) )
        grpRedem:insert( btnRedem2 )
        
        local icoRedem = display.newImage( "img/icoRedem.png" )
        icoRedem:translate(midW - 415, 435)
        grpRedem:insert(icoRedem)
        
        local lblCanjear = display.newText({
            text = "CANJEAR", 
            x = midW - 305, y = 435, 
            fontSize = 30,
            font = native.systemFontBold,   

        })
        lblCanjear:setFillColor( 1 )
        grpRedem:insert(lblCanjear)
        
        -- Animaciones
        transition.to( imgLogo, { time = 500, alpha = 0 })
        transition.to( grpRedem, { time = 500, delay = 500, alpha = 1 })
        transition.to( bgLogo1, { time = 500, width = 320, y = 270, height = 245 })
        transition.to( bgLogo2, { time = 500, width = 300, y = 270, height = 225 })
        
    end
    
    if imgReward then
        imgReward:removeSelf()
        imgReward = nil
    end
    imgReward = display.newImage( item.image, system.TemporaryDirectory )
    imgReward.alpha = 0
    imgReward.height = 225
    imgReward.width = 300
    imgReward:translate(midW - 335, 270)
    grpRedem:insert(imgReward)
    imgReward:toBack()
    transition.to( imgReward, { time = 1000, alpha = 1 })
    
    btnRedem.reward = item
    lblRedemTitle.text = item.name
    lblRedemPoints.text = item.points
end

-------------------------------------
-- Mensaje de puntos
-- @param points puntos a mostrar
------------------------------------
function showPoints(points)
    grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)
    
    local bgShadow = display.newRect( 0, 0, intW, intH )
    bgShadow.alpha = .5
    bgShadow.anchorX = 0
    bgShadow.anchorY = 0
    bgShadow:setFillColor( 0 )
    grpMsg:insert(bgShadow)
    
    local imgBg = display.newImage( "img/bgCheckInPoints.png" )
    imgBg.x = midW
    imgBg.y = midH
    grpMsg:insert(imgBg)
    
    local lblMsg = display.newText({
        text = points, 
        x = midW + 210, y = midH + 90,
        fontSize = 140,
        font = native.systemFontBold,   
        
    })
    lblMsg:setFillColor( 1 )
    grpMsg:insert(lblMsg)
    
    transition.to( grpMsg, { alpha = 1, time = 1000 })
    audio.play( fxCash )
    transition.to( grpMsg, { alpha = 0, time = 500, delay = 2500 })
    transition.to( grpContent, { alpha = 1, time = 500, delay = 2500 })
end

-------------------------------------
-- Mostramos pantalla
------------------------------------
function showList()
    
    grpContent = display.newGroup()
    grpContent.alpha = 0
    screen:insert(grpContent)
    
    local btnBack = display.newImage( "img/btnBack.png" )
    btnBack.x = midW - 335
    btnBack.y = 80
    btnBack:addEventListener( 'tap', tapReturn)
    grpContent:insert(btnBack)
    
    bgLogo1 = display.newRoundedRect( midW - 335, 350, 220, 220, 15 )
    bgLogo1:setFillColor( unpack(cAqua) )
    grpContent:insert( bgLogo1 )
    
    bgLogo2 = display.newRoundedRect( midW - 335, 350, 200, 200, 15 )
    bgLogo2:setFillColor( 1 )
    grpContent:insert( bgLogo2 )
    
    imgLogo = display.newImage( "img/bgTmpLogo.png" )
    imgLogo.x =  midW - 335
    imgLogo.y = 350
    grpContent:insert(imgLogo)
    
    local bgPointsList = display.newImage( "img/bgPointsList.png" )
    bgPointsList.x =  midW - 335
    bgPointsList.y = 600
    grpContent:insert(bgPointsList)
    
    local lblPoints = display.newText({
        text = userPoints, 
        x =  midW - 335, y = 580,
        fontSize = 80,
        font = native.systemFontBold,   
        
    })
    lblPoints:setFillColor( unpack(cMarine) )
    grpContent:insert(lblPoints)
    
    local lblTitle = display.newText({
        text = "RECOMPENSAS DISPONIBLES:", 
        x = midW + 150, y = 60,
        fontSize = 30, width = 600,
        font = native.systemFontBold,   
        
    })
    lblTitle.anchorY = 0
    lblTitle:setFillColor( 1 )
    grpContent:insert(lblTitle)
    
    scrRewards = widget.newScrollView
	{
        top = 100,
		width = 600,
		height = 620,
		horizontalScrollDisabled = true,
        hideBackground = true
	}
    scrRewards.x = midW + 150
	grpContent:insert(scrRewards)
    RestManager.getRewards()
end

-------------------------------------
-- Mostramos recompensas
-- @param items lista de recompensas
------------------------------------
function showRewards(items)
    for z = 1, #items, 1 do 
        local curY = (z*135) - 70
        
        rewards[z] = {}
        rewards[z].reward = items[z]
        local bgR = display.newRoundedRect( 300, curY, 600, 120, 10 )
        bgR:setFillColor( unpack(cAqua) )
        scrRewards:insert( bgR )
        
        rewards[z].bgDesc = display.newRoundedRect( 10, curY, 400, 100, 10 )
        rewards[z].bgDesc.anchorX = 0
        rewards[z].bgDesc:setFillColor( 1 )
        scrRewards:insert( rewards[z].bgDesc )
        
        rewards[z].bgDescR = display.newRect( 360, curY, 100, 100 )
        rewards[z].bgDescR.anchorX = 0
        rewards[z].bgDescR:setFillColor( 1 )
        scrRewards:insert( rewards[z].bgDescR )
        
        local bgPoints = display.newRoundedRect( 470, curY, 120, 100, 10 )
        bgPoints.anchorX = 0
        bgPoints:setFillColor( unpack(cMarine) )
        scrRewards:insert( bgPoints )
        
        local bgPointsL = display.newRect( 470, curY, 80, 100 )
        bgPointsL.anchorX = 0
        bgPointsL:setFillColor( unpack(cMarine) )
        scrRewards:insert( bgPointsL )
        
        rewards[z].lblTitle = display.newText({
            text = items[z].name, 
            x = 225, y = curY - 25,
            fontSize = 24, width = 400, align = "left",
            font = native.systemFontBold,   

        })
        rewards[z].lblTitle:setFillColor( unpack(cMarine) )
        scrRewards:insert( rewards[z].lblTitle )
        
        rewards[z].lblDesc = display.newText({
            text = items[z].description, 
            x = 225, y = curY + 15, height = 42,
            fontSize = 18, width = 400, align = "left",
            font = native.systemFont,   

        })
        rewards[z].lblDesc:setFillColor( unpack(cGrayLow) )
        scrRewards:insert( rewards[z].lblDesc )
        
        local lblPoints = display.newText({
            text = items[z].points, 
            x = 530, y = curY - 10, fontSize = 50,
            font = native.systemFontBold 

        })
        lblPoints:setFillColor( 1 )
        scrRewards:insert( lblPoints )
        
        local lblPointsB = display.newText({
            text = "PUNTOS", 
            x = 530, y = curY + 25, fontSize = 20,
            font = native.systemFontBold 

        })
        lblPointsB:setFillColor( 1 )
        scrRewards:insert( lblPointsB )
        
        if rewards[z].lblTitle.height > 35 then
            rewards[z].lblTitle.y = curY - 20
            rewards[z].lblDesc.y = curY + 28
        end
        
        if tonumber(userPoints) < tonumber(items[z].points) then
            local bgDisabled = display.newRoundedRect( 300, curY, 600, 120, 10 )
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
    
    userId = event.params.user.id
    userPoints = event.params.user.points
    showList()
    if event.params.user.newPoints > 0 then
        showPoints(event.params.user.newPoints)
    else
        transition.to( grpContent, { alpha = 1, time = 1000 })
    end
    
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