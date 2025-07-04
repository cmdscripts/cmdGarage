local allow = true

-- create database structure on first start
MySQL.ready(function()
    local sql = LoadResourceFile(GetCurrentResourceName(), 'sql.sql')
    if sql then
        MySQL.Sync.execute(sql)
    end
end)

-- ESX = nil
-- local allow = true

-- TriggerEvent(Config.esxgetSharedObjectevent, function(obj)
-- 	ESX = obj
-- end)

ESX.RegisterServerCallback('garage:loadVehicles', function(source, cb)
	local ownedCars = {}
	local s = source
	local x = ESX.GetPlayerFromId(s)
	
    if allow then
        if Config.showcarsfromcertainjob then
            MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 1 AND job = @job', {['@owner'] = x.identifier, ['@job'] = Config.certainjobname}, function(vehicles)

                for _,v in pairs(vehicles) do
                    local vehicle = json.decode(v.vehicle)
                    table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate, name = v.nickname, isFav = v.isFav, class = v.type})
                end
                cb(ownedCars)
            end)
        else
            MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 1', {['@owner'] = x.identifier}, function(vehicles)

                for _,v in pairs(vehicles) do
                    local vehicle = json.decode(v.vehicle)
                    table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate, name = v.nickname, isFav = v.isFav, class = v.type})
                end
                cb(ownedCars)
            end)
        end
    end
end)

ESX.RegisterServerCallback('garage:isOwned', function(source, cb, plate)
	local s = source
	local x = ESX.GetPlayerFromId(s)

    if allow then
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?', {plate, x.getIdentifier()}, function(result)
            if #result ~= 0 then
                if result[1].owner == x.identifier then
                    cb({result[1].nickname, result[1].isFav})
                else
                    cb(nil)
                end
            end
        end)
    end
end)

ESX.RegisterServerCallback('garage:loadVehicle', function(source, cb, plate)
	
	local s = source
	local x = ESX.GetPlayerFromId(s)
	
    if allow then
        MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE `plate` = @plate', {['@plate'] = plate}, function(vehicle)
            
            cb(vehicle)
        end)
    end
end)

RegisterNetEvent('garage:setvehfav')
AddEventHandler('garage:setvehfav', function(plate, state)
	if allow then
        MySQL.Sync.execute("UPDATE owned_vehicles SET isFav = @isFav WHERE plate = @plate", {['@plate'] = plate, ['@isFav'] = state})
    end
end)

RegisterNetEvent('garage:setvehnickname')
AddEventHandler('garage:setvehnickname', function(plate, nickname)
    if allow then
	    MySQL.Sync.execute("UPDATE owned_vehicles SET nickname = @nickname WHERE plate = @plate", {['@plate'] = plate, ['@nickname'] = nickname})
    end
end)

RegisterNetEvent('garage:changeState')
AddEventHandler('garage:changeState', function(plate, state)
    if allow then
	    MySQL.Sync.execute("UPDATE owned_vehicles SET `stored` = @state WHERE `plate` = @plate", {['@state'] = state, ['@plate'] = plate})
    end
end)

RegisterNetEvent('garage:saveProps')
AddEventHandler('garage:saveProps', function(plate, props)
    local xProps = json.encode(props)
    if allow then
        MySQL.Sync.execute("UPDATE owned_vehicles SET `vehicle` = ? WHERE `plate` = ?", {xProps, plate})
    end
end)
