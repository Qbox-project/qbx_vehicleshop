-- Variables
local config = require 'config.server'
local sharedConfig = require 'config.shared'
local financeTimer = {}
local coreVehicles = exports.qbx_core:GetVehiclesByName()
local saleTimeout = {}

-- Handlers
-- Store game time for player when they load
RegisterNetEvent('qbx_vehicleshop:server:addPlayer', function(citizenid)
    financeTimer[citizenid] = os.time()
end)

-- Deduct stored game time from player on logout
RegisterNetEvent('qbx_vehicleshop:server:removePlayer', function(citizenid)
    if not financeTimer[citizenid] then return end
    local finance = require 'server.finance'

    local playTime = financeTimer[citizenid]
    local vehicles = finance.fetchFinancedVehicleEntitiesByCitizenId(citizenid)
    for i = 1, #vehicles do
        local v = vehicles[i]
        if v.balance >= 1 then
            local newTime = math.floor(v.financetime - (((os.time() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            finance.updateVehicleEntityFinanceTime(newTime, v.vehicleId)
        end
    end
    financeTimer[citizenid] = nil
end)

-- Deduct stored game time from player on quit because we can't get citizenid
AddEventHandler('playerDropped', function()
    local src = source
    local finance = require 'server.finance'
    local license = GetPlayerIdentifierByType(src, 'license2') or GetPlayerIdentifierByType(src, 'license')
    if not license then return end
    local vehicles = finance.fetchFinancedVehicleEntitiesByCitizenId(license)
    if not vehicles then return end
    for i = 1, #vehicles do
        local v = vehicles[i]
        local playTime = financeTimer[v.citizenid]
        if v.balance >= 1 and playTime then
            local newTime = math.floor(v.financetime - (((os.time() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            finance.updateVehicleEntityFinanceTime(newTime, v.vehicleId)
        end
    end
    if vehicles[1] and financeTimer[vehicles[1].citizenid] then
        financeTimer[vehicles[1].citizenid] = nil
    end
end)

-- Functions

---@param vehiclePrice number
---@param downPayment number
---@param paymentamount number
---@return integer balance owed on the vehicle
---@return integer numPayments to pay off the balance
local function calculateFinance(vehiclePrice, downPayment, paymentamount)
    local balance = vehiclePrice - downPayment
    local vehPaymentAmount = balance / paymentamount
    return qbx.math.round(balance), qbx.math.round(vehPaymentAmount)
end

---@class FinancedVehicle
---@field paymentAmount number
---@field balance number
---@field paymentsLeft integer

---@param paymentAmount number paid
---@param vehData FinancedVehicle
---@return integer newBalance
---@return integer newPayment
---@return integer numPaymentsLeft
local function calculateNewFinance(paymentAmount, vehData)
    local newBalance = tonumber(vehData.balance - paymentAmount) --[[@as number]]
    local minusPayment = vehData.paymentsLeft - 1
    local newPaymentsLeft = newBalance / minusPayment
    local newPayment = newBalance / newPaymentsLeft
    return qbx.math.round(newBalance), qbx.math.round(newPayment), newPaymentsLeft
end

-- Callbacks
lib.callback.register('qbx_vehicleshop:server:GetVehiclesByName', function(source)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local vehicles = exports.qbx_vehicles:GetPlayerVehicles({
        citizenid = player.PlayerData.citizenid
    })

    local financeVehicles = require 'server.finance'.fetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    for i = 1, #financeVehicles do
        local v = financeVehicles[i]
        local vehicle = vehicles[v.vehicleId]
        vehicle.balance = v.balance
        vehicle.paymentamount = v.paymentamount
        vehicle.paymentsleft = v.paymentsleft
        vehicle.financetime = v.financetime
    end
    return vehicles[1] and vehicles
end)
-- Events

-- Brute force vehicle deletion
---@param netId number
RegisterNetEvent('qbx_vehicleshop:server:deleteVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(vehicle)
end)

-- Sync vehicle for other players
---@param data unknown
RegisterNetEvent('qbx_vehicleshop:server:swapVehicle', function(data)
    TriggerClientEvent('qbx_vehicleshop:client:swapVehicle', -1, data)
end)

-- Send customer for test drive
RegisterNetEvent('qbx_vehicleshop:server:customTestDrive', function(vehicle, playerId)
    local src = source
    local target = tonumber(playerId) --[[@as number]]
    if not exports.qbx_core:GetPlayer(target) then
        exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
        return
    end
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target))) < 3 then
        TriggerClientEvent('qbx_vehicleshop:client:testDrive', target, { vehicle = vehicle })
    else
        exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end
end)

---Checks if player has enough money, then returns a string based on the currency.
---@param price number
---@param cash number
---@param bank number
---@return 'cash'|'bank'|nil
local function findChargeableCurrencyType(price, cash, bank)
    if cash >= price then
        return 'cash'
    elseif bank >= price then
        return 'bank'
    else
        return nil
    end
end

---takes money from cash if player has amount, otherwise bank
---@param src number
---@param amount number
---@return boolean success if money was removed
local function removeMoney(src, amount)
    local player = exports.qbx_core:GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank

    local currencyType = findChargeableCurrencyType(amount, cash, bank)
    if not currencyType then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    player.Functions.RemoveMoney(currencyType, amount)
    return true
end

-- Make a finance payment
RegisterNetEvent('qbx_vehicleshop:server:financePayment', function(paymentAmount, vehData)
    local src = source
    local vehId = vehData.vehId
    paymentAmount = tonumber(paymentAmount) --[[@as number]]
    local minPayment = tonumber(vehData.paymentAmount) --[[@as number]]
    local timer = (config.finance.paymentInterval * 60)
    local newBalance, newPaymentsLeft, newPayment = calculateNewFinance(paymentAmount, vehData)

    if newBalance <= 0 then
        exports.qbx_core:Notify(src, locale('error.overpaid'), 'error')
        return
    end

    if paymentAmount < minPayment then
        exports.qbx_core:Notify(src, locale('error.minimumallowed')..lib.math.groupdigits(minPayment), 'error')
        return
    end

    if not removeMoney(src, paymentAmount) then return end

    require 'server.finance'.updateVehicleFinance({
        balance = newBalance,
        payment = newPayment,
        paymentsLeft = newPaymentsLeft,
        timer = timer
    }, vehId)
end)


-- Pay off vehice in full
RegisterNetEvent('qbx_vehicleshop:server:financePaymentFull', function(data)
    local src = source
    local vehBalance = data.vehBalance
    local vehId = data.vehId

    if vehBalance == 0 then
        exports.qbx_core:Notify(src, locale('error.alreadypaid'), 'error')
        return
    end

    if not removeMoney(src, vehBalance) then return end

    require 'server.finance'.updateVehicleFinance({
        balance = 0,
        payment = 0,
        paymentsLeft = 0,
        timer = 0,
    }, vehId)
end)

---@param src number
---@param data {coords: vector4, vehicleId: number, modelName: string, plate?: string}
---@return number|nil
local function spawnVehicle(src, data)
    local coords, vehicleId = data.coords, data.vehicleId
    local vehicle = vehicleId and exports.qbx_vehicles:GetPlayerVehicle(vehicleId) or data
    if not vehicle then return end

    local plate = vehicle.plate or vehicle.props.plate

    local netId, veh = qbx.spawnVehicle({
        model = vehicle.modelName,
        spawnSource = coords,
        warp = GetPlayerPed(src),
        props = {
            plate
        }
    })

    if not netId or netId == 0 then return end

    if not veh or veh == 0 then return end

    if vehicleId then Entity(veh).state:set('vehicleid', vehicleId, false) end

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
    return netId
end
lib.callback.register('qbx_vehicleshop:server:spawnVehicle', spawnVehicle)

-- Buy public vehicle outright
RegisterNetEvent('qbx_vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    vehicle = vehicle.buyVehicle
    local vehiclePrice = coreVehicles[vehicle].price
    local currencyType = findChargeableCurrencyType(vehiclePrice, player.PlayerData.money.cash, player.PlayerData.money.bank)
    if not currencyType then
        return exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local vehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = player.PlayerData.citizenid,
    })
    exports.qbx_core:Notify(src, locale('success.purchased'), 'success')

    local shopId = lib.callback.await('qbx_vehicleshop:client:getPlayerCurrentShop', src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
    player.Functions.RemoveMoney(currencyType, vehiclePrice, 'vehicle-bought-in-showroom')
end)

-- Finance public vehicle
RegisterNetEvent('qbx_vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = coreVehicles[vehicle].price
    local minDown = tonumber(qbx.math.round((sharedConfig.finance.minimumDown / 100) * vehiclePrice)) --[[@as number]]
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

    local currencyType = findChargeableCurrencyType(downPayment, player.PlayerData.money.cash, player.PlayerData.money.bank)

    if not currencyType then
        return exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
    local cid = player.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60)

    local vehicleId = require 'server.finance'.insertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            citizenId = cid,
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

    local shopId = lib.callback.await('qbx_vehicleshop:client:getPlayerCurrentShop', src)

    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })

    player.Functions.RemoveMoney(currencyType, downPayment, 'vehicle-bought-in-showroom')
end)

---@param src number
---@param target table
---@param price number
---@param downPayment number
---@return boolean success
local function sellShowroomVehicleTransact(src, target, price, downPayment)
    local player = exports.qbx_core:GetPlayer(src)
    local currencyType = findChargeableCurrencyType(downPayment, target.PlayerData.money.cash, target.PlayerData.money.bank)
    if not currencyType then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    target.Functions.RemoveMoney(currencyType, downPayment, 'vehicle-bought-in-showroom')

    local commission = qbx.math.round(price * config.commissionRate)
    player.Functions.AddMoney('bank', price * config.commissionRate)
    exports.qbx_core:Notify(src, locale('success.earned_commission', lib.math.groupdigits(commission)), 'success')

    exports['Renewed-Banking']:addAccountMoney(player.PlayerData.job.name, price)
    exports.qbx_core:Notify(target.PlayerData.source, locale('success.purchased'), 'success')
    return true
end

-- Sell vehicle to customer
RegisterNetEvent('qbx_vehicleshop:server:sellShowroomVehicle', function(data, playerid)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerid))

    if not target then
        return exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end

    local vehicle = data
    local vehiclePrice = coreVehicles[vehicle].price
    local cid = target.PlayerData.citizenid

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, vehiclePrice) then return end

    local vehicleId = exports.qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = cid,
    })

    local shopId = lib.callback.await('qbx_vehicleshop:client:getPlayerCurrentShop', target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
end)

-- Finance vehicle to customer
RegisterNetEvent('qbx_vehicleshop:server:sellfinanceVehicle', function(downPayment, paymentAmount, vehicle, playerid)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerid))

    if not target then
        return exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end

    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]
    local vehiclePrice = coreVehicles[vehicle].price
    local minDown = tonumber(qbx.math.round((sharedConfig.finance.minimumDown / 100) * vehiclePrice)) --[[@as number]]

    if downPayment > vehiclePrice then
        return exports.qbx_core:Notify(src, locale('error.notworth'), 'error')
    end
    if downPayment < minDown then
        return exports.qbx_core:Notify(src, locale('error.downtoosmall'), 'error')
    end
    if paymentAmount > sharedConfig.finance.maximumPayments then
        return exports.qbx_core:Notify(src, locale('error.exceededmax'), 'error')
    end

    local cid = target.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60)
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, downPayment) then return end

    local vehicleId = require 'server.finance'.insertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            citizenId = cid,
            model = vehicle,
        },
        vehicleFinance = {
            balance = balance,
            payment = vehPaymentAmount,
            paymentsLeft = paymentAmount,
            timer = timer,
        }
    })

    local shopId = lib.callback.await('qbx_vehicleshop:client:getPlayerCurrentShop', target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
end)

-- Check if payment is due
RegisterNetEvent('qbx_vehicleshop:server:checkFinance', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    exports.qbx_core:Notify(src, locale('general.paymentduein', config.finance.paymentWarning))
    Wait(config.finance.paymentWarning * 60000)

    local vehicles = require 'server.finance'.fetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    for i = 1, #vehicles do
        local v = vehicles[i]
        local plate = v.plate
        if config.deleteUnpaidFinancedVehicle then
            exports.qbx_vehicles:DeletePlayerVehicles('vehicleId', v.id)
        else
            MySQL.update('UPDATE player_vehicles SET citizenid = ? WHERE id = ?', {'REPO-'..v.citizenid, v.id}) -- Use this if you don't want them to be deleted
        end

        exports.qbx_core:Notify(src, locale('error.repossessed', plate), 'error')
    end
end)

-- Transfer vehicle to player in passenger seat
lib.addCommand('transfervehicle', {help = locale('general.command_transfervehicle'), params = {
    {name = 'id', type = 'playerId', help = locale('general.command_transfervehicle_help')},
    {name = 'amount', type = 'number', help = locale('general.command_transfervehicle_amount'), optional = true}}}, function(source, args)
    local qbx_core = exports.qbx_core
    local qbx_vehicles = exports.qbx_vehicles
    local src = source
    local buyerId = args.id
    local sellAmount = args.amount or 0

    if src == buyerId then
        return qbx_core:Notify(src, locale('error.selftransfer'), 'error')
    end
    if saleTimeout[src] then
        return qbx_core:Notify(src, locale('error.sale_timeout'), 'error')
    end
    if buyerId == 0 then
        return qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end
    local ped = GetPlayerPed(src)

    local targetPed = GetPlayerPed(buyerId)
    if targetPed == 0 then
        return qbx_core:Notify(src, locale('error.buyerinfo'), 'error')
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return qbx_core:Notify(src, locale('error.notinveh'), 'error')
    end

    local vehicleId = Entity(vehicle).state.vehicleid or qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    if not vehicleId then return end

    local player = qbx_core:GetPlayer(src)
    local target = qbx_core:GetPlayer(buyerId)
    local row = qbx_vehicles:GetPlayerVehicle(vehicleId)

    if not row then return end

    if config.finance.preventSelling then
        local financeRow = require 'server.finance'.fetchFinancedVehicleEntityById(row.id)
        if financeRow and financeRow.balance > 0 then
            return qbx_core:Notify(src, locale('error.financed'), 'error')
        end
    end
    if row.citizenid ~= player.PlayerData.citizenid then
        return qbx_core:Notify(src, locale('error.notown'), 'error')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0 then
        return qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end
    local targetcid = target.PlayerData.citizenid
    if not target then
        return qbx_core:Notify(src, locale('error.buyerinfo'), 'error')
    end

    saleTimeout[src] = true
    SetTimeout(config.saleTimeout, function()
        saleTimeout[src] = false
    end)

    lib.callback('qbx_vehicleshop:client:confirmTrade', buyerId, function(approved)
        if not approved then
            qbx_core:Notify(src, locale('error.buyerdeclined'), 'error')
            return
        end
        if sellAmount > 0 then
            local currencyType = findChargeableCurrencyType(sellAmount, target.PlayerData.money.cash, target.PlayerData.money.bank)
            if not currencyType then
                return qbx_core:Notify(src, locale('error.buyertoopoor'), 'error')
            end
            player.Functions.AddMoney(currencyType, sellAmount)
            target.Functions.RemoveMoney(currencyType, sellAmount)
        end
        qbx_vehicles:SetPlayerVehicleOwner(row.id, targetcid)
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, row.plate)
        local sellerMessage = sellAmount > 0 and locale('success.soldfor') .. lib.math.groupdigits(sellAmount) or locale('success.gifted')
        local buyerMessage = sellAmount > 0 and locale('success.boughtfor') .. lib.math.groupdigits(sellAmount) or locale('success.received_gift')
        qbx_core:Notify(src, sellerMessage, 'success')
        qbx_core:Notify(buyerId, buyerMessage, 'success')
    end, GetEntityModel(vehicle), sellAmount)
end)

---@param vehicleId integer
---@return boolean
local function isFinanced(vehicleId)
    return require 'server.finance'.fetchIsFinanced(vehicleId)
end

exports('IsFinanced', isFinanced)