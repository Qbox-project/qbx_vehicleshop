---@class InsertVehicleEntityRequest
---@field citizenId string
---@field model string
---@field plate string

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
    local vehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
        model = request.insertVehicleEntityRequest.model,
        citizenid = request.insertVehicleEntityRequest.citizenId,
        props = {
            plate = request.insertVehicleEntityRequest.plate
        }
    })
    MySQL.insert('INSERT INTO vehicle_financing (vehicleId, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?)', {
        vehicleId,
        request.vehicleFinance.balance,
        request.vehicleFinance.payment,
        request.vehicleFinance.paymentsLeft,
        request.vehicleFinance.timer
    })

    return vehicleId
end

---@alias VehicleEntity table

---@class VehicleFinancingEntity
---@field vehicleId integer
---@field balance number
---@field paymentamount number
---@field paymentsleft integer
---@field financetime number

---@param citizenId string
---@return VehicleEntity[]
function FetchVehicleEntitiesByCitizenId(citizenId)
    return MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId})
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
---@param vehicleId integer
function UpdateVehicleEntityFinanceTime(time, vehicleId)
    MySQL.update('UPDATE vehicle_financing SET financetime = ? WHERE vehicleId = ?', {time, vehicleId})
end

---@param vehicleFinance VehicleFinanceServer
---@param plate string
function UpdateVehicleFinance(vehicleFinance, plate)
    local vehicleId = exports.qbx_vehicles:GetVehicleIdByPlate(plate)
    if vehicleFinance.balance == 0 then
        MySQL.query('DELETE FROM vehicle_financing WHERE vehicleId = ?', {
            vehicleId
        })
    else
        MySQL.update('UPDATE vehicle_financing AS vf INNER JOIN player_vehicles AS pv ON vf.vehicleId = pv.id SET vf.balance = ?, vf.paymentamount = ?, vf.paymentsleft = ?, vf.financetime = ? WHERE pv.id = ?', {
            vehicleFinance.balance,
            vehicleFinance.payment,
            vehicleFinance.paymentsLeft,
            vehicleFinance.timer,
            vehicleId
        })
    end
end

---@param citizenId string
---@param license string
---@param vehicleId integer
function UpdateVehicleEntityOwner(citizenId, license, vehicleId)
    MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE id = ?', {citizenId, license, vehicleId})
end

---@param id integer
---@return VehicleFinancingEntity
function FetchFinancedVehicleEntityById(id)
    return MySQL.single.await('SELECT * FROM vehicle_financing WHERE vehicleId = ? AND balance > 0 AND financetime < 1', {id})
end

---@param vehicleId integer
---@return boolean
function FetchIsFinanced(vehicleId)
    return MySQL.scalar.await('SELECT 1 FROM vehicle_financing WHERE vehicleId = ? AND balance > 0', {
        vehicleId
    }) ~= nil
end

---@param citizenId string
---@return VehicleFinancingEntity
function FetchFinancedVehicleEntitiesByCitizenId(citizenId)
    return MySQL.query.await('SELECT vehicle_financing.* FROM vehicle_financing INNER JOIN player_vehicles ON player_vehicles.citizenid = ? WHERE vehicle_financing.vehicleId = player_vehicles.id AND vehicle_financing.balance > 0 AND vehicle_financing.financetime > 1', {citizenId})
end

---@param license string
---@return VehicleFinancingEntity
function FetchFinancedVehicleEntitiesByLicense(license)
    return MySQL.query.await('SELECT vf.*, p.citizenid FROM vehicle_financing AS vf INNER JOIN players AS p ON p.citizenid = ? INNER JOIN player_vehicles AS pv ON pv.citizenid = p.citizenid AND vf.balance > 0 AND vf.financetime < 1', {license})
end