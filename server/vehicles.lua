local vehicles = {}
local blocklist = {}
local VEHICLES = exports.qbx_core:GetVehiclesByName()
local sharedConfig = require 'config.shared'.vehicles
local count = 0

local function insertVehicle(vehicleData, shopType)
    count += 1
    vehicles[count] = {
        shopType = shopType,
        category = vehicleData.category,
        model = vehicleData.model,
    }
end

for i = 1, #sharedConfig.blocklist do
    local blockveh = sharedConfig.blocklist[i]
    blocklist[blockveh] = true
end

for k, vehicle in pairs(VEHICLES) do
    local vehicleShop = sharedConfig.models[k] or sharedConfig.categories[vehicle.category] or sharedConfig.default

    if blocklist[k] then
        lib.print.debug('Vehicle is blocked. Skipping: ' .. k)
    elseif not vehicleShop then
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

return {
    vehicles = vehicles,
    count = count,
}
