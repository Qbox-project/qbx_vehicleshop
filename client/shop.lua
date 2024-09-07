local shops = {}

local function loadShopCategory(category, insideShop, targetVehicle)
    local shop = shops[category]
    if shop then return shop end -- return if exist

    shop = {}
    shops[category] = shop

    local config = require 'config.client'
    local VEHICLES = exports.qbx_core:GetVehiclesByName()

    local function insertVehicle(data)
        shop[#shop + 1] = {
            title = ('%s %s'):format(data.brand, data.name),
            description = locale('menus.veh_price')..lib.math.groupdigits(data.price),
            serverEvent = 'qbx_vehicleshop:server:swapVehicle',
            args = {
                toVehicle = data.model,
                targetVehicle = targetVehicle,
                closestShop = insideShop
            }
        }
    end

    for k, vehicle in pairs(VEHICLES) do
        if vehicle.category == category then
            local vehicleShop = config.models[k] or config.categories[vehicle.category] or config.default

            if not vehicleShop then
                lib.print.debug('Vehicle not found in config. Skipping: ' .. k)
            else
                if type(vehicleShop) == 'table' then
                    for i = 1, #vehicleShop do
                        if vehicleShop[i] == insideShop then
                            insertVehicle(vehicle)
                        end
                    end
                elseif vehicleShop == insideShop then
                    insertVehicle(vehicle)
                end
            end
        end
    end

    table.sort(shop, function(a, b)
        local _, aName = string.strsplit(' ', string.upper(a.title), 2)
        local _, bName = string.strsplit(' ', string.upper(b.title), 2)

        return aName < bName
    end)

    return shop
end

local function resetShop()
    shops = {}
end

return {
    loadShop = loadShopCategory,
    resetShop = resetShop
}