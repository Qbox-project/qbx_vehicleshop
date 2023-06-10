---@class InsertVehicleEntityRequest
---@field license string
---@field citizenId string
---@field model string
---@field plate string

---@param request InsertVehicleEntityRequest
function InsertVehicleEntity(request)
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        request.license,
        request.citizenId,
        request.model,
        joaat(request.model),
        '{}',
        request.plate,
        'pillboxgarage',
        0
    })
end

---@class VehicleFinanceServer
---@field balance number
---@field payment number
---@field paymentsLeft integer
---@field timer number

---@class InsertVehicleEntityWithFinanceRequest
---@field insertVehicleEntityRequest InsertVehicleEntityRequest
---@field vehicleFinance VehicleFinanceServer

---@param request InsertVehicleEntityWithFinanceRequest
function InsertVehicleEntityWithFinance(request)
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        request.insertVehicleEntityRequest.license,
        request.insertVehicleEntityRequest.citizenId,
        request.insertVehicleEntityRequest.model,
        joaat(request.insertVehicleEntityRequest.model),
        '{}',
        request.insertVehicleEntityRequest.plate,
        'pillboxgarage',
        0,
        request.vehicleFinance.balance,
        request.vehicleFinance.payment,
        request.vehicleFinance.paymentsLeft,
        request.vehicleFinance.timer
    })
end

---@alias VehicleEntity table

---@param citizenId string
---@return VehicleEntity[]
function FetchVehicleEntitiesByCitizenId(citizenId)
    return MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId})
end

---@param license string
---@return VehicleEntity[]
function FetchVehicleEntitiesByLicense(license)
    return MySQL.query.await('SELECT * FROM player_vehicles WHERE license = ?', {license})
end

---@param plate string
---@return VehicleEntity
function FetchVehicleEntityByPlate(plate)
    return MySQL.single.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
end

---@param plate string
---@return boolean
function DoesVehicleEntityExist(plate)
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM player_vehicles WHERE plate = ?', {plate})
    return count > 0
end

---@param time number
---@param plate string
function UpdateVehicleEntityFinanceTime(time, plate)
    MySQL.update('UPDATE player_vehicles SET financetime = ? WHERE plate = ?', {time, plate})
end

---@param vehicleFinance VehicleFinanceServer
---@param plate string
function UpdateVehicleFinance(vehicleFinance, plate)
    MySQL.update('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {
        vehicleFinance.balance,
        vehicleFinance.payment,
        vehicleFinance.paymentsLeft,
        vehicleFinance.timer,
        plate
    })
end

---@param citizenId string
---@param license string
---@param plate string
function UpdateVehicleEntityOwner(citizenId, license, plate)
    MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?', {citizenId, license, plate})
end

---@param citizenId string
---@return VehicleEntity[]
function FetchFinancedVehicleEntitiesByCitizenId(citizenId)
    return MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND balance > 0 AND financetime < 1', {citizenId})
end

---@param plate string
function DeleteVehicleEntity(plate)
    MySQL.query('DELETE FROM player_vehicles WHERE plate = ?', {plate})
end
