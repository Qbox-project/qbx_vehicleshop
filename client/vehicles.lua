local vehicles = {}
local VEHICLES = exports.qbx_core:GetVehiclesByName()
local config = require 'config.client'
local groupdigits = lib.math.groupdigits
local count = 0

local function insertVehicle(data, shopType)
    count += 1
    vehicles[count] = {
        shopType = shopType,
        category = data.category,

        title = ('%s %s'):format(data.brand, data.name),
        description = ('%s%s'):format(locale('menus.veh_price'), groupdigits(data.price)),
        serverEvent = 'qbx_vehicleshop:server:swapVehicle',
        args = {
            toVehicle = data.model,
        }
    }
end

for k, vehicle in pairs(VEHICLES) do
    local vehicleShop = config.models[k] or config.categories[vehicle.category] or config.default

    if not vehicleShop then
        lib.print.debug('Vehicle not found in config. Skipping: ' .. k)
    else
        if type(vehicleShop) == 'table' then
            for i = 1, #vehicleShop do
                insertVehicle(vehicle, vehicleShop[i])
            end
        else
            insertVehicle(vehicle, vehicleShop)
        end
    end
end

table.sort(vehicles, function(a, b)
    local _, aName = string.strsplit(' ', string.upper(a.title), 2)
    local _, bName = string.strsplit(' ', string.upper(b.title), 2)

    return aName < bName
end)

return vehicles