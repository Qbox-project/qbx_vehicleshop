local config = require 'config.server'
local sharedConfig = require 'config.shared'

if not sharedConfig.finance.enable then return end

local financeStorage = require 'server.storage'
local financeTimer = {}

function SetHasFinanced(src, bool)
    financeTimer[src].hasFinanced = bool
end

---@param src number
---@param citizenid string
local function addPlayerToFinanceTimer(src, citizenid)
    citizenid = citizenid or exports.qbx_core:GetPlayer(src).PlayerData.citizenid

    local hasFinanced = financeStorage.hasFinancedVehicles(citizenid)
    if hasFinanced then
        exports.qbx_core:Notify(src, locale('general.paymentduein', config.finance.paymentWarning))
    end

    financeTimer[src] = {
        citizenid = citizenid,
        time = os.time(),
        hasFinanced = hasFinanced
    }
end

CreateThread(function()
    local players = exports.qbx_core:GetPlayersData()
    if players then
        for i = 1, #players do
            local player = players[i]
            addPlayerToFinanceTimer(player.source, player.citizenid)
        end
    end
end)

---@param src number
local function updatePlayerFinanceTime(src)
    local playerData = financeTimer[src]
    if not playerData then return end

    local vehicles = financeStorage.fetchFinancedVehicleEntitiesByCitizenId(playerData.citizenid)

    local playTime = math.floor((os.time() - playerData.time) / 60)
    for i = 1, #vehicles do
        local v = vehicles[i]
        local newTime = lib.math.clamp(v.financetime - playTime, 0, math.maxinteger)

        if v.balance >= 1 then
            financeStorage.updateVehicleEntityFinanceTime(newTime, v.vehicleId)
        end
    end

    financeTimer[src] = nil
end

---@param src number
local function checkFinancedVehicles(src)
    local financeData = financeTimer[src]
    if not financeData.hasFinanced then return end

    local citizenid = financeData.citizenid
    local time = math.floor((os.time() - financeData.time) / 60)
    local vehicles = financeStorage.fetchFinancedVehicleEntitiesByCitizenId(citizenid)

    if not vehicles then
        financeTimer[src].hasFinanced = false
        return
    end
    local paymentReminder = false
    for i = 1, #vehicles do
        local v = vehicles[i]
        local timeLeft = v.financetime - time
        if timeLeft <= 0 then
            if config.deleteUnpaidFinancedVehicle then
                exports.qbx_vehicles:DeletePlayerVehicles('vehicleId', v.id)
            else
                exports.qbx_vehicles:SetPlayerVehicleOwner(v.id, nil)
            end
            exports.qbx_core:Notify(src, locale('error.repossessed', v.plate), 'error')
        elseif timeLeft <= config.finance.paymentWarning then
            paymentReminder = true
        end
    end

    if paymentReminder then
        exports.qbx_core:Notify(src, locale('general.paymentduein', config.finance.paymentWarning))
    end
end

AddEventHandler('playerDropped', function()
    local src = source
    updatePlayerFinanceTime(src)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    updatePlayerFinanceTime(src)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local playerData = exports.qbx_core:GetPlayer(src).PlayerData
    addPlayerToFinanceTimer(src, playerData.citizenid)
end)

lib.cron.new(config.finance.cronSchedule, function()
    for src in pairs(financeTimer) do
        checkFinancedVehicles(src)
    end
end)

---@param vehiclePrice number
---@param downPayment number
---@param paymentamount number
---@return integer balance owed on the vehicle
---@return integer numPayments to pay off the balance
local function calculateFinance(vehiclePrice, downPayment, paymentamount)
    local balance = vehiclePrice - downPayment
    local vehPaymentAmount = balance / paymentamount

    return lib.math.round(balance), lib.math.round(vehPaymentAmount)
end

---@param paymentAmount number paid
---@param vehData VehicleFinancingEntity
---@return integer newBalance
---@return integer newPayment
---@return integer numPaymentsLeft
local function calculateNewFinance(paymentAmount, vehData)
    local newBalance = tonumber(vehData.balance - paymentAmount) --[[@as number]]
    local minusPayment = vehData.paymentsleft - 1
    local newPaymentsLeft = newBalance / minusPayment
    local newPayment = newBalance / newPaymentsLeft

    return lib.math.round(newBalance), lib.math.round(newPayment), newPaymentsLeft
end


---@param paymentAmount number
---@param vehId number
RegisterNetEvent('qbx_vehicleshop:server:financePayment', function(paymentAmount, vehId)
    local src = source
    local vehData = financeStorage.fetchFinancedVehicleEntityById(vehId)

    paymentAmount = tonumber(paymentAmount) --[[@as number]]

    local minPayment = tonumber(vehData.paymentamount) --[[@as number]]
    local timer = (config.finance.paymentInterval * 60) + (math.floor((os.time() - financeTimer[src].time) / 60))
    local newBalance, newPaymentsLeft, newPayment = calculateNewFinance(paymentAmount, vehData)

    if newBalance <= 0 then
        exports.qbx_core:Notify(src, locale('error.overpaid'), 'error')
        return
    end

    if paymentAmount < minPayment then
        exports.qbx_core:Notify(src, locale('error.minimumallowed')..lib.math.groupdigits(minPayment), 'error')
        return
    end

    if not RemoveMoney(src, paymentAmount, 'vehicle-finance-payment') then return end

    financeStorage.updateVehicleFinance({
        balance = newBalance,
        payment = newPayment,
        paymentsLeft = newPaymentsLeft,
        timer = timer
    }, vehId)
end)


---@param vehId number
RegisterNetEvent('qbx_vehicleshop:server:financePaymentFull', function(vehId)
    local src = source
    local vehData = financeStorage.fetchFinancedVehicleEntityById(vehId)

    if not RemoveMoney(src, vehData.balance, 'vehicle-finance-payment-full') then return end

    financeStorage.updateVehicleFinance({
        balance = 0,
        payment = 0,
        paymentsLeft = 0,
        timer = 0,
    }, vehId)
end)

---@param downPayment number
---@param paymentAmount number
---@param vehicle string
---@param playerId string|number
RegisterNetEvent('qbx_vehicleshop:server:sellfinanceVehicle', function(downPayment, paymentAmount, vehicle, playerId)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerId))

    if not target then
        return exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end

    local shopId = GetShopZone(target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.qbx_core:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]

    local vehiclePrice = COREVEHICLES[vehicle].price
    local minDown = tonumber(lib.math.round((sharedConfig.finance.minimumDown / 100) * vehiclePrice)) --[[@as number]]

    if downPayment > vehiclePrice then
        return exports.qbx_core:Notify(src, locale('error.notworth'), 'error')
    end

    if downPayment < minDown then
        return exports.qbx_core:Notify(src, locale('error.downtoosmall'), 'error')
    end

    if paymentAmount > sharedConfig.finance.maximumPayments then
        return exports.qbx_core:Notify(src, locale('error.exceededmax'), 'error')
    end

    local citizenId = target.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60) + (math.floor((os.time() - financeTimer[src].time) / 60))
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)

    if not SellShowroomVehicleTransact(src, target, vehiclePrice, downPayment) then return end

    local vehicleId = financeStorage.insertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            citizenId = citizenId,
            model = vehicle,
        },

        vehicleFinance = {
            balance = balance,
            payment = vehPaymentAmount,
            paymentsLeft = paymentAmount,
            timer = timer,
        }
    })

    SpawnVehicle(src, {
        coords = coords,
        vehicleId = vehicleId
    })
    financeTimer[target.PlayerData.source].hasFinanced = true
end)

---@param downPayment number
---@param paymentAmount number
---@param vehicle string
RegisterNetEvent('qbx_vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source

    local shopId = GetShopZone(src)

    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not CheckVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local coords = GetClearSpawnArea(shop.vehicleSpawns)
    if not coords then
        return exports.qbx_core:Notify(src, locale('error.no_clear_spawn'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = COREVEHICLES[vehicle].price
    local minDown = tonumber(lib.math.round((sharedConfig.finance.minimumDown / 100) * vehiclePrice)) --[[@as number]]

    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]

    if downPayment > vehiclePrice then
        return exports.qbx_core:Notify(src, locale('error.notworth'), 'error')
    end

    if downPayment < minDown then
        return exports.qbx_core:Notify(src, locale('error.downtoosmall'), 'error')
    end

    if paymentAmount > sharedConfig.finance.maximumPayments then
        return exports.qbx_core:Notify(src, locale('error.exceededmax'), 'error')
    end

    if not RemoveMoney(src, downPayment, 'vehicle-financed-in-showroom') then
        return exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
    local citizenId = player.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60) + (math.floor((os.time() - financeTimer[src].time) / 60))

    local vehicleId = financeStorage.insertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            citizenId = citizenId,
            model = vehicle,
        },

        vehicleFinance = {
            balance = balance,
            payment = vehPaymentAmount,
            paymentsLeft = paymentAmount,
            timer = timer,
        }
    })

    exports.qbx_core:Notify(src, locale('success.purchased'), 'success')

    SpawnVehicle(src, {
        coords = coords,
        vehicleId = vehicleId
    })

    financeTimer[src].hasFinanced = true
end)

---@param source number
lib.callback.register('qbx_vehicleshop:server:GetFinancedVehicles', function(source)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local financeVehicles = financeStorage.fetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    local vehicles = {}

    for i = 1, #financeVehicles do
        local v = financeVehicles[i]
        local vehicle = exports.qbx_vehicles:GetPlayerVehicle(v.vehicleId)

        if vehicle then
            vehicle.balance = v.balance
            vehicle.paymentamount = v.paymentamount
            vehicle.paymentsleft = v.paymentsleft
            vehicle.financetime = v.financetime
        end
        vehicles[#vehicles + 1] = vehicle
    end

    return vehicles[1] and vehicles
end)

---@param vehicleId integer
---@return boolean
local function isFinanced(vehicleId)
    return financeStorage.fetchIsFinanced(vehicleId)
end
exports('IsFinanced', isFinanced)
