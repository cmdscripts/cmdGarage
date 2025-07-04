-- ESX = nil

-- Citizen.CreateThread(function()
--     while ESX == nil do
--         TriggerEvent(Config.esxgetSharedObjectevent, function(obj) ESX = obj end)
--         Citizen.Wait(0)
--     end
-- end)

local currentgarage = nil

function toggleField(bool, name)
    SetNuiFocus(bool, bool)

    SendNUIMessage({
        action = 'show',
        state = bool,
        name = name
    })
end

function AddCar(model, plate, nickname, isFav)
    SendNUIMessage({
        action = 'addCar',
        model = model,
        plate = plate,
        nickname = nickname,
        isFav = isFav
    })
end


function GetAvailableVehicleSpawnPoint(station)
    local found = false 
    local foundSpawnPoint = nil

    for k,v in pairs(Config.Garages[station].SpawnPoints) do
        if ESX.Game.IsSpawnPointClear(v.coords, v.radius) then
            found = true
            foundSpawnPoint = v
            break
        end
    end

    if found then
        return true, foundSpawnPoint
    else
        ESX.ShowNotification("Alle Ausparkpunkte besetzt!")
        return false
    end
end


RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)

        for k,v in pairs(Config.Garages) do
            local dist = GetDistanceBetweenCoords(pos, v.location)

            if dist <= 2.0 then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um auf die Garage zuzugreifen")

                if IsControlJustReleased(0, 38) then
                    toggleField(true, v.name)
                    currentgarage = k
                end
            end
        end
    end
end)

function getVehicleType(class)
    for vehicleType, classList in pairs(Config.VehicleCategories) do
        for _, classNumber in ipairs(classList) do
            if classNumber == class then
                return vehicleType
            end
        end
    end
end

RegisterNUICallback('enable-parkout', function(data, cb)

    local garageType = Config.Garages[currentgarage].type

    ESX.TriggerServerCallback('garage:loadVehicles', function(ownedCars)
        if #ownedCars == 0 then
            TriggerEvent(Config.esxprefix.."showNotification", "Du hast keine Fahrzeuge.")
        else
            for k,v in pairs(ownedCars) do

                if(v.class == garageType) then
                    local hashVehicule = v.vehicle.model
                    local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
                    local modelName = GetLabelText(aheadVehName)
                    AddCar(aheadVehName, v.plate, v.name, v.isFav)
                end
            end
        end
    end)
end)

RegisterNUICallback('enable-parking', function(data, cb)

    local garageType = Config.Garages[currentgarage].type

    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 25.0)

    for k, v in pairs(vehicles) do

        local vehicleType = getVehicleType(GetVehicleClass(v))

        print(GetVehicleNumberPlateText(v))

        ESX.TriggerServerCallback('garage:isOwned', function(owned)
            if (owned ~= nil and garageType == vehicleType) then
                AddCar(GetDisplayNameFromVehicleModel(GetEntityModel(v)), GetVehicleNumberPlateText(v), owned[1], owned[2])
            end
        end, GetVehicleNumberPlateText(v))
    end
    
    cb('ok')
end)

RegisterNUICallback('setvehfav', function(data, cb)
    TriggerServerEvent("garage:setvehfav", data.plate, data.state)
end)

RegisterNUICallback('rename', function(data, cb)
    TriggerServerEvent("garage:setvehnickname", data.plate, data.nickname)
    TriggerEvent(Config.esxprefix..'showNotification','Du hast denn Nickname von dem Fahrzeug mit dem Kennzeichen: ' .. data.plate .. ' zu ' .. data.nickname.. ' Geändert')
end)

RegisterNUICallback('park-in', function(data, cb)
    local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(PlayerPedId()), 25.0)

    for k,v in pairs(vehicles) do
        if GetVehicleNumberPlateText(v) == data.plate then
            TriggerServerEvent('garage:saveProps', data.plate, ESX.Game.GetVehicleProperties(v), getVehicleType(GetVehicleClass(v)))
            TriggerServerEvent('garage:changeState', data.plate, 1)
            ESX.Game.DeleteVehicle(v)
        end
    end
end)

RegisterNUICallback('park-out', function(data, cb)
    
    ESX.TriggerServerCallback('garage:loadVehicle', function(vehicle)
        local props = json.decode(vehicle[1].vehicle)
        local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(currentgarage)

        if foundSpawn then
            ESX.Game.SpawnVehicle(props.model, spawnPoint.coords, spawnPoint.heading, function(callback_vehicle)
                ESX.Game.SetVehicleProperties(callback_vehicle, props)
                SetVehRadioStation(callback_vehicle, "OFF")
                if Config.teleportinvehicle then
                    TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
                end
            end)
        end

        TriggerServerEvent('garage:changeState', data.plate, 0)
    end, data.plate)
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Garages) do
        local blip = AddBlipForCoord(v.location)

        SetBlipSprite(blip, 524)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 0)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garage")
        EndTextCommandSetBlipName(blip)
    end
end)