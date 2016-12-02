local composer = require( "composer" )
local widget = require( "widget" )
local RestManager = require( "src.RestManager" )
local fxTap = audio.loadSound( "fx/tap.wav")
local fxCash = audio.loadSound( "fx/cash.wav")
require('src.Globals')

-- Grupos y Contenedores
local scene = composer.newScene()
local lblTicket, lblMonto, bgTicket, bgMonto, bgRed
local txtActive = ''


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
-- Tap sobre un textfield
-- @param event objeto evento
------------------------------------
function tapField(event)
    bgTicket:setFillColor( unpack(cAqua) ) 
    bgMonto:setFillColor( unpack(cAqua) )
    
    local t = event.target
    t:setFillColor( unpack(cMarine) ) 
    txtActive = t.field
    return true
end

-------------------------------------
-- Tap sobre teclado numerico
-- @param event objeto evento
------------------------------------
function tapBtnKey(event)
    local val = event.target.value
    if val == 'OK' then
        if lblMonto.data == '' then
            transition.to( bgRed, { alpha = 1, time = 400 })
            transition.to( bgRed, { alpha = .01, time = 400, delay = 450 })
        else
        end
    else
        if not(txtActive == '') then
            if txtActive == 'ticket' then
                if val == '<' then
                    if not(lblTicket.text == '') then
                       lblTicket.text = lblTicket.text:sub(1, -2)
                    end
                else
                    lblTicket.text = lblTicket.text..val
                end
            else
                if val == '<' then
                    if not(lblMonto.data == '') then
                       lblMonto.data = lblMonto.data:sub(1, -2)
                    end
                else
                    if not(lblMonto.data == '' and val == '0') and string.len(lblMonto.data) < 6  then
                        lblMonto.data = lblMonto.data..val
                    end
                end
                if lblMonto.data == '' then
                    lblMonto.text = ''
                else
                    lblMonto.text = '$'..numformat(tonumber(lblMonto.data))
                end
            end
        end
    end
    return true
end

function numformat(number)
    if number < 0 or number == 0 or not number then
        return 0
    elseif number > 0 and number < 1000000 then 
        local t = {}
        thousands = ','
        decimal = '.'
        local int = math.floor(number)
        local rest = number % 1
        if int == 0 then
            t[#t+1] = 0
        else
            local digits = math.log10(int)
            local segments = math.floor(digits / 3)
            t[#t+1] = math.floor(int / 1000^segments)
            for i = segments-1, 0, -1 do
                t[#t+1] = thousands
                t[#t+1] = ("%03d"):format(math.floor(int / 1000^i) % 1000)
            end
        end
        if rest ~= 0 then
            t[#t+1] = decimal
            rest = math.floor(rest * 10^6)
            while rest % 10 == 0 do
                rest = rest / 10
            end
            t[#t+1] = rest
        end
        local s = table.concat(t)
        return s
    else
        return number
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
    
    local btnBack = display.newImage( "img/iconPrev.png" )
    btnBack.x = midW - 450
    btnBack.y = 110
    btnBack:addEventListener( 'tap', tapReturn)
    screen:insert(btnBack)
    
    -- Fields
    local lblTicket0 = display.newText({
        text = "NUMERO DE TICKET:", 
        x = midW, y = midH - 280,
        fontSize = 28, width = 700, align = "left",
        font = fontSemiBold,   
        
    })
    lblTicket0:setFillColor( 1 )
    screen:insert(lblTicket0)
    
    local lblMonto0 = display.newText({
        text = "MONTO DEL CONSUMO:", 
        x = midW, y = midH - 190,
        fontSize = 28, width = 700, align = "left",
        font = fontSemiBold,   
        
    })
    lblMonto0:setFillColor( 1 )
    screen:insert(lblMonto0)
    
    bgTicket = display.newRoundedRect( midW + 185, midH - 280, 350, 70, 5 )
    bgTicket:setFillColor( unpack(cAqua) ) 
    bgTicket.field = 'ticket'
    bgTicket:addEventListener( 'tap', tapField)
    screen:insert(bgTicket)
    
    bgMonto = display.newRoundedRect( midW + 185, midH - 190, 350, 70, 5 )
    bgMonto:setFillColor( unpack(cAqua) )
    bgMonto.field = 'monto'
    bgMonto:addEventListener( 'tap', tapField) 
    screen:insert(bgMonto)
    
    local bgField1 = display.newRoundedRect( midW + 185, midH - 280, 340, 60, 5 )
    bgField1:setFillColor( unpack(cWhite) ) 
    screen:insert(bgField1)
    
    local bgField2 = display.newRoundedRect( midW + 185, midH - 190, 340, 60, 5 )
    bgField2:setFillColor( unpack(cWhite) ) 
    screen:insert(bgField2)
    
    bgRed = display.newRoundedRect( midW + 185, midH - 190, 340, 60, 5 )
    bgRed:setFillColor( .5, 0, 0 ) 
    bgRed.alpha = .01
    screen:insert(bgRed)
    
    lblTicket = display.newText({
        text = "", 
        x = midW + 185, y = midH - 280,
        fontSize = 28, width = 300, align = "right",
        font = fontSemiBold,   
        
    })
    lblTicket:setFillColor( 0 )
    screen:insert(lblTicket)
    
    lblMonto = display.newText({
        text = "", 
        x = midW + 185, y = midH - 190,
        fontSize = 28, width = 300, align = "right",
        font = fontSemiBold,   
        
    })
    lblMonto.data = ''
    lblMonto:setFillColor( 0 )
    screen:insert(lblMonto)
    
    -- Keyboard
    local resid, posX, posY
    local chart = {'7','8','9','4','5','6','1','2','3','<','0','OK'}
    for z = 1, 12, 1 do 
        resid = ( z % 3 )
        if resid == 1 then posX = -170
        elseif resid == 2 then posX = 0
        else posX = 170 posX = 170 end
        
        posY = math.floor((z+2) / 3 )
        posY = -180 + (120*posY) 
        
        local bgBtn1 = display.newRoundedRect( midW + posX, midH + posY, 120, 100, 5 )
        bgBtn1:setFillColor( unpack(cWhite) ) 
        bgBtn1.alpha = .7
        bgBtn1.value = chart[z]
        screen:insert(bgBtn1)
        bgBtn1:addEventListener( 'tap', tapBtnKey ) 
        
        local bgBtn2 = display.newRoundedRect( midW + posX, midH + posY, 114, 94, 5 )
        bgBtn2:setFillColor( {
            type = 'gradient',
            color1 = { unpack(cTurquesa) }, 
            color2 = { unpack(cPurPle) },
            direction = "bottom"
        } ) 
        screen:insert(bgBtn2)
        if z == 10 or z == 12 then
             bgBtn2:setFillColor( unpack(cPurPle) ) 
        end
        
        if z == 10 then
            local iconBackSpace = display.newImage( "img/iconBackSpace.png" )
            iconBackSpace:translate(midW + posX, midH + posY)
            screen:insert(iconBackSpace)
        else
            local lblChart = display.newText({
                text = chart[z], 
                x = midW + posX, y = midH + posY,
                fontSize = 40, font = fontSemiBold
            })
            lblChart:setFillColor( unpack(cWhite) )
            screen:insert(lblChart)
        end
        
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