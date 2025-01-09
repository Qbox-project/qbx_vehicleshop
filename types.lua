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

---A `vehicle_financing` row joined with its corresponding `player_vehicles` row.
---@class JoinedVehicleFinancingEntity : VehicleFinancingEntity
---@field id integer
---@field plate string

---@class DealershipZone -- Zone definition for dealership
---@field shape vector3[] -- poly zone points. All Z values should be the same
---@field size vector3 -- Size of the showroom zones
---@field targetDistance number -- Distance for targets inside zone

---@class DealershipBlip -- Blip definition for dealership
---@field label string -- Blip label
---@field coords vector3 -- Blip coordinates
---@field show boolean -- Whether to show the blip
---@field sprite integer -- Blip sprite
---@field color integer -- Blip color

---@class DealershipVehicle -- Showroom spot definition
---@field coords vector4 -- coordinates to spawn showroom vehicle
---@field vehicle string -- vehicle model

---@class TestDriveConfig -- Test drive configuration
---@field limit number -- Time for test drive in minutes
---@field endBehavior 'return'|'destroy'|'none' -- 'none' will not do anything, 'return' will return the player to the dealership and destroy the vehicle, 'destroy' will destroy the vehicle and leave player at current position

---@class Dealership -- Dealership configuration
---@field type 'free-use'|'managed' -- 'free-use' allows players to purchase vehicles without any restrictions, 'managed' requires a job to purchase vehicles
---@field job string? -- Only required if type is 'managed'
---@field zone DealershipZone
---@field blip DealershipBlip
---@field categories table<string, string> -- Key is the category name, value is the category label
---@field showroomVehicles DealershipVehicle[]
---@field testDrive TestDriveConfig
---@field returnLocation vector3 -- Location to return the vehicle to for test drives
---@field vehicleSpawns vector4[] -- Locations to spawn purchased vehicles