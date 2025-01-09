local config = require 'config.server'
local allowedVehicles = require 'server.vehicles'

---@param vehicle string Vehicle model name to check if allowed for purchase/testdrive/etc.
---@param shop string? Shop name to check if vehicle is allowed in that shop
---@return boolean
function CheckVehicleList(vehicle, shop)
    for i = 1, allowedVehicles.count do
        local allowedVeh = allowedVehicles.vehicles[i]
        if allowedVeh.model == vehicle and (not shop or allowedVeh.shopType == shop) then
            return true
        end
    end

    return false
end

local shops = require 'config.shared'.shops
local shopZones = {}

---@param source number
---@return string?
function GetShopZone(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    for i = 1, #shopZones do
        local zone = shopZones[i]
        if zone:contains(coords) then
            return zone.name
        end
    end
end

-- Create shop zones for point checking
CreateThread(function()
    for shopName, shop in pairs(shops) do
        shopZones[#shopZones + 1] = lib.zones.poly({
            name = shopName,
            points = shop.zone.shape,
            thickness = 5,
        })

        for i = 1, #shop.showroomVehicles do
            local vehicle = shop.showroomVehicles[i]

            if not CheckVehicleList(vehicle.vehicle, shopName) then
                lib.print.warn(('Vehicle "%s" is a showroom vehicle for shop "%s" but is not allowed to be bought there'):format(vehicle.vehicle, shopName))
            end
        end
    end
end)

---@param price number
---@param cash number
---@param bank number
---@return 'cash'|'bank'|nil
function FindChargeableCurrencyType(price, cash, bank)
    if cash >= price then
        return 'cash'
    elseif bank >= price then
        return 'bank'
    else
        return
    end
end

---@param src number
---@param amount number
---@param reason string?
---@return boolean success if money was removed
function RemoveMoney(src, amount, reason)
    local player = exports.qbx_core:GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local currencyType = FindChargeableCurrencyType(amount, cash, bank)

    if not currencyType then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    return config.removePlayerFunds(player, currencyType, amount, reason)
end

---@param spawns vector4[]
---@return vector4 | nil
function GetClearSpawnArea(spawns)
    for i = 1, #spawns do
        local spawn = spawns[i]

        if #lib.getNearbyVehicles(spawn.xyz) == 0 then
            return spawn
        end
    end
end

---@param src number
---@param data {coords: vector4, vehicleId?: number, modelName: string, plate?: string, props?: {plate: string}}
---@return number|nil
function SpawnVehicle(src, data)
    local coords, vehicleId = data.coords, data.vehicleId
    local newVehicle = vehicleId and exports.qbx_vehicles:GetPlayerVehicle(vehicleId) or data
    if not newVehicle then return end

    local plate = newVehicle.plate or newVehicle.props.plate

    local netId, vehicle = qbx.spawnVehicle({
        model = newVehicle.modelName,
        spawnSource = coords,
        warp = GetPlayerPed(src),
        props = {
            plate = plate
        }
    })

    if not netId or netId == 0 or not vehicle or vehicle == 0 then return end

    if vehicleId then
        Entity(vehicle).state:set('vehicleid', vehicleId, false)
    end

    config.giveKeys(src, plate, vehicle)

    return netId
end