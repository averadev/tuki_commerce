    --Include sqlite
local RestManager = {}

	local mime = require("mime")
	local json = require("json")
	local crypto = require("crypto")
    local composer = require( "composer" )
    local DBManager = require('src.DBManager')
    local dbConfig = DBManager.getSettings()

    local site = "http://192.168.1.102/tuki_ws/"
    --local site = "http://mytuki.com/api/"
	
    -------------------------------------
    -- Encode URL
    -- @param str string to encode
    ------------------------------------
	function urlencode(str)
          if (str) then
              str = string.gsub (str, "\n", "\r\n")
              str = string.gsub (str, "([^%w ])",
              function ( c ) return string.format ("%%%02X", string.byte( c )) end)
              str = string.gsub (str, " ", "%%20")
          end
          return str    
    end

    -------------------------------------
    -- Carga de la imagen del servidor o de TemporaryDirectory
    -- @param str string to encode
    ------------------------------------
    function loadImage(obj)
        -- Next Image
        if obj.idx < #obj.items then
            -- Add to index
            obj.idx = obj.idx + 1
            -- Determinamos si la imagen existe
            if obj.items[obj.idx].image then
                local img = obj.items[obj.idx].image
                local path = system.pathForFile( img, system.TemporaryDirectory )
                local fhd = io.open( path )
                if fhd then
                    fhd:close()
                    loadImage(obj)
                else
                    local function imageListener( event )
                        if ( event.isError ) then
                        else
                            event.target:removeSelf()
                            event.target = nil
                            loadImage(obj)
                        end
                    end
                    -- Descargamos de la nube
                    display.loadRemoteImage( site..obj.path..img, "GET", imageListener, img, system.TemporaryDirectory ) 
                end
            else
                loadImage(obj)
            end
        else
            -- Dirigimos al metodo de home
            if obj.method == "Home" then
                toHome()
            elseif obj.method == "HomeR" then
                homeRewards(obj.items)
            end
        end
    end

    -------------------------------------
    -- Carga de la imagen del servidor o de TemporaryDirectory
    -- @param str string to encode
    ------------------------------------
    function getImgR(img, parent, x, y, w, h)
        local path = system.pathForFile( img, system.TemporaryDirectory )
        local fhd = io.open( path )
        if fhd then
            fhd:close()
            local imgReward = display.newImage( img, system.TemporaryDirectory )
            imgReward.width = w
            imgReward.height = h
            imgReward.x = x
            imgReward.y = y
            parent:insert(imgReward)
        else
            local function imageListener( event )
                if ( event.isError ) then
                else
                    event.target.width = w
                    event.target.height = h
                    event.target.x = x
                    event.target.y = y
                    parent:insert(event.target)
                end
            end
            -- Descargamos de la nube
            display.loadRemoteImage( site.."assets/img/api/rewards/"..img, "GET", imageListener, img, system.TemporaryDirectory ) 
        end
    end    


    -------------------------------------
    -- Actualiza config
    ------------------------------------
    RestManager.reloadConfig = function()
        dbConfig = DBManager.getSettings()  
    end

    -------------------------------------
    -- Obtener Recomensas
    ------------------------------------
    RestManager.getRewards = function()
		local url = site.."commerce/getRewards/format/json/idCommerce/"..dbConfig.idCommerce
        
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if "src.Home" == composer.getSceneName( "current" ) then
                    loadImage({idx = 0, method = 'HomeR', path = "assets/img/api/rewards/", items = data.items})
                else
                    showRewards(data.items)
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Validar QR
    -- @param qr codigo tarjeta
    ------------------------------------
    RestManager.checkPoints = function(qr)
        local url = site.."commerce/checkPoints/format/json/idCommerce/"..dbConfig.idCommerce.."/qr/"..qr
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                showPoints(data.points)
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
    end

    -------------------------------------
    -- Validar QR
    -- @param qr codigo tarjeta
    ------------------------------------
    RestManager.validateQR = function(qr)
		local url = site.."commerce/validateQR/format/json/idCommerce/"..dbConfig.idCommerce.."/idBranch/"..dbConfig.idBranch.."/qr/"..qr
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.cashier then
                    if data.success then
                        toCashier(data.cashier)
                    else
                        qrError(true)
                    end
                elseif data.newUser then
                    toNewUser(data.user)
                elseif data.user then
                    toRewards(data.user)
                else
                    qrError(false)
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Validar QR
    -- @param qr codigo tarjeta
    ------------------------------------
    RestManager.validateQrReward = function(qr)
		local url = site.."commerce/validateQrReward/format/json/idCommerce/"..dbConfig.idCommerce.."/qr/"..qr
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    if tonumber(data.user.points) < tonumber(data.reward.points) then
                        RestManager.validateQR(data.user.id)
                    else
                        toQrReward(data)
                    end
                    
                else
                    if data.mensaje then
                        showMsg(data.mensaje)
                    else
                        qrError(false)
                    end
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Insertar Redencion
    -- @param idUser Id Usuario
    -- @param points puntos a descontar
    ------------------------------------
    RestManager.insertRedemption = function(idUser, idReward, points)
		local url = site.."commerce/insertRedemption/format/json/status/1/idCommerce/"..dbConfig.idCommerce.."/idBranch/"..dbConfig.idBranch.."/idReward/"..idReward.."/idUser/"..idUser.."/points/"..points
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
            end
            return true
        end
        -- Do request
        
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Actualizar Redencion
    -- @param status Tipo actualizacion
    -- @param idUser Id Usuario
    -- @param points puntos a descontar
    ------------------------------------
    RestManager.setRedemption = function(status, idRedemption, idCashier, points)
		local url = site.."commerce/setRedemption/format/json/status/"..status.."/idCommerce/"..dbConfig.idCommerce.."/idRedemption/"..idRedemption.."/idCashier/"..idCashier.."/points/"..points
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Insertar Redencion
    -- @param idUser Id Usuario
    -- @param points puntos a descontar
    ------------------------------------
    RestManager.getRedenciones = function(idUser, points)
		local url = site.."commerce/getRedenciones/format/json/idBranch/"..dbConfig.idBranch
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                showRedenciones(data.items)
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Actualizar Usuario
    -- @param idUser Id Usuario
    -- @param name Nombre
    -- @param email Correo Electronico
    ------------------------------------
    RestManager.updateUser = function(idUser, name, email)
		local url = site.."commerce/updateUser/format/json/idUser/"..idUser.."/name/"..urlencode(name).."/email/"..urlencode(email)
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                toRewards()
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Verifica clave de acceso
    -- @param key Clave de acceso
    ------------------------------------
    RestManager.verifyPassword = function(password)
		local url = site.."commerce/verifyPassword/format/json/password/"..password
        
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    local br = data.branch[1]
                    DBManager.updateConfig(br.idCommerce, br.idBranch, br.image)
                    loadImage({idx = 0, method = 'Home', path = "assets/img/api/commerce/", items = data.branch})
                else
                    showMsg("Clave incorrecta :(")
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    -------------------------------------
    -- Verifica salida de la sucursal
    -- @param key Clave de acceso
    ------------------------------------
    RestManager.validateExit = function(password)
		local url = site.."commerce/validateExit/format/json/idBranch/"..dbConfig.idBranch.."/password/"..password
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    DBManager.updateConfig(0, 0, '')
                    toLogin()
                else
                    showMsg("Clave incorrecta :(")
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    --------------------------------4-----
    -- Test connection
    ------------------------------------
    RestManager.networkConnection = function()
        local netConn = require('socket').connect('www.google.com', 80)
        if netConn == nil then
            return false
        end
        netConn:close()
        return true
    end

    

	
	
return RestManager