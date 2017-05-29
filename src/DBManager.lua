--Include sqlite
local dbManager = {}

	require "sqlite3"
    local lfs = require "lfs"
	local path, db

	-- Open rackem.db.  If the file doesn't exist it will be created
	local function openConnection( )
        local pathBase = system.pathForFile(nil, system.DocumentsDirectory)
        if findLast(pathBase, "/data/data") > -1 or findLast(pathBase, "/data/user") > -1 then
            local newFile = pathBase:gsub("/app_data", "") .. "/databases/tuki.db"
            local fhd = io.open( newFile )
            if fhd then
                fhd:close()
            else
                local success = lfs.chdir(  pathBase:gsub("/app_data", "") )
                if success then
                    lfs.mkdir( "databases" )
                end
            end
            db = sqlite3.open( newFile )
        else
            db = sqlite3.open( system.pathForFile("tuki.db", system.DocumentsDirectory) )
        end
	end

    -- Find substring
    function findLast(haystack, needle)
        local i=haystack:match(".*"..needle.."()")
        if i==nil then return -1 else return i-1 end
    end

	local function closeConnection( )
		if db and db:isopen() then
			db:close()
		end     
	end
    
    local function actualizarDB(table, column, typeC, value)
		-- Verify Version APP
        local oldVersion = true
		for row in db:nrows("PRAGMA table_info("..table..");") do
            if row.name == column then
                oldVersion = false
            end
        end
    
        if oldVersion then
            local query = "ALTER TABLE "..table.." ADD COLUMN "..column.." "..typeC..";"
            db:exec( query )
        
            local query = "UPDATE "..table.." SET "..column.." = '"..value.."';"
            if typeC == 'INTEGER' then
                query = "UPDATE "..table.." SET "..column.." = "..value..";"
            end
            print(query)
            db:exec( query )
        end
	end
	 
	-- Handle the applicationExit event to close the db
	local function onSystemEvent( event )
	    if( event.type == "applicationExit" ) then              
	        closeConnection()
	    end
	end

    dbManager.clearQR = function()
		openConnection( )
        local query = ''
        query = "UPDATE config SET qr = ''"
        db:exec( query )
		closeConnection( )
	end

    dbManager.updateConfig = function(idCommerce, idBranch, logo)
		openConnection( )
        local query = ''
        query = "UPDATE config SET idCommerce = "..idCommerce..", idBranch = "..idBranch..", logo = '"..logo.."';"
        db:exec( query )
		closeConnection( )
	end

    dbManager.updateComUser = function(idComUser, nameUser)
		openConnection( )
        local query = ''
        query = "UPDATE config SET idComUser = "..idComUser..", nameUser = '"..nameUser.."';"
        db:exec( query )
		closeConnection( )
	end

	-- obtiene los datos de configuracion
	dbManager.getSettings = function()
		local result = {}
		openConnection( )
		for row in db:nrows("SELECT * FROM config;") do
			closeConnection( )
			return  row
		end
		closeConnection( )
		return 1
	end
    
	-- Setup squema if it doesn't exist
	dbManager.setupSquema = function()
		openConnection( )
		
		local query = "CREATE TABLE IF NOT EXISTS config (id TEXT PRIMARY KEY, idCommerce INTEGER, idBranch INTEGER, logo TEXT, qr TEXT);"		
        db:exec( query )
    
        actualizarDB("config", "idComUser", "INTEGER", 0)
        actualizarDB("config", "nameUser", "TEXT", "")

        for row in db:nrows("SELECT * FROM config;") do
            closeConnection( )
			do return end
		end

        query = "INSERT INTO config VALUES (1, 0, 0, '', '', 0, '');"
        
		db:exec( query )
    
		closeConnection( )
    
        return 1
	end
    
	
	-- Setup the system listener to catch applicationExit
	Runtime:addEventListener( "system", onSystemEvent )

return dbManager