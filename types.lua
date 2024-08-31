---@meta

---@class VehicleFinanceClient
---@field vehiclePlate string
---@field balance number
---@field paymentsLeft integer
---@field paymentAmount number
---@field brand string
---@field name string
---@field vehId number

---@class FinancedVehicle
---@field paymentAmount number
---@field balance number
---@field paymentsLeft integer

---@class InsertVehicleEntityRequest
---@field citizenId string
---@field model string

---@class VehicleFinanceServer
---@field balance number
---@field payment number
---@field paymentsLeft integer
---@field timer number

---@class InsertVehicleEntityWithFinanceRequest
---@field insertVehicleEntityRequest InsertVehicleEntityRequest
---@field vehicleFinance VehicleFinanceServer

---@class VehicleFinancingEntity
---@field vehicleId integer
---@field balance number
---@field paymentamount number
---@field paymentsleft integer
---@field financetime number