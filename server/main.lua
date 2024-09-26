lib.versionCheck('Qbox-project/qbx_vehicleshop')
assert(lib.checkDependency('qbx_vehicles', '1.4.1'), 'qbx_vehicles v1.4.1 or higher is required')

local config = require 'config.server'
local sharedConfig = require 'config.shared'
local financeStorage = require 'server.storage'
local allowedVehicles = require 'server.vehicles'
local financeTimer = {}
local coreVehicles = exports.qbx_core:GetVehiclesByName()
local shopZones = {}
local saleTimeout = {}
local testDrives = {}
local qbx_vehicles = exports.qbx_vehicles

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
                qbx_vehicles:DeletePlayerVehicles('vehicleId', v.id)
            else
                qbx_vehicles:SetPlayerVehicleOwner(v.id, nil)
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

---@param vehicle string Vehicle model name to check if allowed for purchase/testdrive/etc.
---@param shop string? Shop name to check if vehicle is allowed in that shop
---@return boolean
local function checkVehicleList(vehicle, shop)
    for i = 1, allowedVehicles.count do
        local allowedVeh = allowedVehicles.vehicles[i]
        if allowedVeh.model == vehicle then
            if shop and allowedVeh.shopType == shop then
                return true
            elseif not shop then
                return true
            end
        end
    end
    return false
end

---@param data {toVehicle: string}
RegisterNetEvent('qbx_vehicleshop:server:swapVehicle', function(data)
    if not checkVehicleList(data.toVehicle) then return end
    TriggerClientEvent('qbx_vehicleshop:client:swapVehicle', -1, data)
end)

---@param source number
---@return string?
local function getShopZone(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    for i = 1, #shopZones do
        local zone = shopZones[i]
        if zone:contains(coords) then
            return zone.name
        end
    end
end

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

---@param source number
lib.callback.register('qbx_vehicleshop:server:GetFinancedVehicles', function(source)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local financeVehicles = financeStorage.fetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    local vehicles = {}

    for i = 1, #financeVehicles do
        local v = financeVehicles[i]
        local vehicle = qbx_vehicles:GetPlayerVehicle(v.vehicleId)

        if vehicle then
            vehicle.balance = v.balance
            vehicle.paymentamount = v.paymentamount
            vehicle.paymentsleft = v.paymentsleft
            vehicle.financetime = v.financetime
        end
        vehicles[#vehicles+1] = vehicle
    end

    return vehicles[1] and vehicles
end)

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
        return
    end
end

---@param src number
---@param amount number
---@param reason string?
---@return boolean success if money was removed
local function removeMoney(src, amount, reason)
    local player = exports.qbx_core:GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local currencyType = findChargeableCurrencyType(amount, cash, bank)

    if not currencyType then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    return player.Functions.RemoveMoney(currencyType, amount, reason)
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

    if not removeMoney(src, paymentAmount, 'vehicle-finance-payment') then return end

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

    if not removeMoney(src, vehData.balance, 'vehicle-finance-payment-full') then return end

    financeStorage.updateVehicleFinance({
        balance = 0,
        payment = 0,
        paymentsLeft = 0,
        timer = 0,
    }, vehId)
end)

---@param src number
---@param data {coords: vector4, vehicleId?: number, modelName: string, plate?: string, props?: {plate: string}}
---@return number|nil
local function spawnVehicle(src, data)
    local coords, vehicleId = data.coords, data.vehicleId
    local vehicle = vehicleId and qbx_vehicles:GetPlayerVehicle(vehicleId) or data
    if not vehicle then return end

    local plate = vehicle.plate or vehicle.props.plate

    local netId, veh = qbx.spawnVehicle({
        model = vehicle.modelName,
        spawnSource = coords,
        warp = GetPlayerPed(src),
        props = {
            plate = plate
        }
    })

    if not netId or netId == 0 then return end

    if not veh or veh == 0 then return end

    if vehicleId then Entity(veh).state:set('vehicleid', vehicleId, false) end

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)

    return netId
end

---@param data {vehicle: string}
RegisterNetEvent('qbx_vehicleshop:server:testDrive', function(data)
    local src = source

    if Player(src).state.isInTestDrive then
        return exports.qbx_core:Notify(src, locale('error.alreadytestdriving'), 'error')
    end

    local shopId = getShopZone(src)
    if not shopId then return end

    if not checkVehicleList(data.vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local testDrive = sharedConfig.shops[shopId].testDrive
    local plate = 'TEST'..lib.string.random('1111')

    local netId = spawnVehicle(src, {
        modelName = data.vehicle,
        coords = testDrive.spawn,
        plate = plate
    })

    testDrives[src] = netId
    Player(src).state:set('isInTestDrive', true, true)
end)

---@param vehicle string
---@param playerId string|number
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

AddStateBagChangeHandler('isInTestDrive', nil, function(bagName, _, value)
    if value then return end

    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    local netId = testDrives[plySrc]
    if not netId then return end

    local vehicle = NetworkGetEntityFromNetworkId(testDrives[plySrc])

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
    testDrives[plySrc] = nil
end)

---@param vehicleData {buyVehicle: string}
RegisterNetEvent('qbx_vehicleshop:server:buyShowroomVehicle', function(vehicleData)
    local src = source

    local shopId = getShopZone(src)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    local vehicle = vehicleData.buyVehicle

    if not checkVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = coreVehicles[vehicle].price
    if not removeMoney(src, vehiclePrice, 'vehicle-bought-in-showroom') then
        return exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local vehicleId = qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = player.PlayerData.citizenid,
    })

    exports.qbx_core:Notify(src, locale('success.purchased'), 'success')


    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
end)

---@param downPayment number
---@param paymentAmount number
---@param vehicle string
RegisterNetEvent('qbx_vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source

    local shopId = getShopZone(src)

    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not checkVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = coreVehicles[vehicle].price
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

    if not removeMoney(src, downPayment, 'vehicle-financed-in-showroom') then
        return exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
    end

    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
    local cid = player.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60) + (math.floor((os.time() - financeTimer[src].time) / 60))

    local vehicleId = financeStorage.insertVehicleEntityWithFinance({
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

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })

    financeTimer[src].hasFinanced = true
end)

---@param src number
---@param target table
---@param price number
---@param downPayment number
---@return boolean success
local function sellShowroomVehicleTransact(src, target, price, downPayment)
    local player = exports.qbx_core:GetPlayer(src)

    if not removeMoney(target.PlayerData.source, downPayment, 'vehicle-bought-in-showroom') then
        exports.qbx_core:Notify(src, locale('error.notenoughmoney'), 'error')
        return false
    end

    local commission = lib.math.round(price * config.commissionRate)
    player.Functions.AddMoney('bank', commission)
    exports.qbx_core:Notify(src, locale('success.earned_commission', lib.math.groupdigits(commission)), 'success')

    exports['Renewed-Banking']:addAccountMoney(player.PlayerData.job.name, price)
    exports.qbx_core:Notify(target.PlayerData.source, locale('success.purchased'), 'success')

    return true
end

---@param vehicle string
---@param playerId string|number
RegisterNetEvent('qbx_vehicleshop:server:sellShowroomVehicle', function(vehicle, playerId)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerId))

    if not target then
        return exports.qbx_core:Notify(src, locale('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return exports.qbx_core:Notify(src, locale('error.playertoofar'), 'error')
    end

    local shopId = getShopZone(target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not checkVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    local vehiclePrice = coreVehicles[vehicle].price
    local cid = target.PlayerData.citizenid

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, vehiclePrice) then return end

    local vehicleId = qbx_vehicles:CreatePlayerVehicle({
        model = vehicle,
        citizenid = cid,
    })

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
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

    local shopId = getShopZone(target.PlayerData.source)
    local shop = sharedConfig.shops[shopId]
    if not shop then return end

    if not checkVehicleList(vehicle, shopId) then
        return exports.qbx_core:Notify(src, locale('error.notallowed'), 'error')
    end

    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]

    local vehiclePrice = coreVehicles[vehicle].price
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

    local cid = target.PlayerData.citizenid
    local timer = (config.finance.paymentInterval * 60) + (math.floor((os.time() - financeTimer[src].time) / 60))
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, downPayment) then return end

    local vehicleId = financeStorage.insertVehicleEntityWithFinance({
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

    spawnVehicle(src, {
        coords = shop.vehicleSpawn,
        vehicleId = vehicleId
    })
    financeTimer[target.PlayerData.source].hasFinanced = true
end)

-- Transfer vehicle to player in passenger seat
lib.addCommand('transfervehicle', {
    help = locale('general.command_transfervehicle'),
    params = {
        {
            name = 'id',
            type = 'playerId',
            help = locale('general.command_transfervehicle_help')
        },
        {
            name = 'amount',
            type = 'number',
            help = locale('general.command_transfervehicle_amount'),
            optional = true
        }
    }
}, function(source, args)
    local buyerId = args.id
    local sellAmount = args.amount or 0

    if source == buyerId then
        return exports.qbx_core:Notify(source, locale('error.selftransfer'), 'error')
    end
    if saleTimeout[source] then
        return exports.qbx_core:Notify(source, locale('error.sale_timeout'), 'error')
    end
    if buyerId == 0 then
        return exports.qbx_core:Notify(source, locale('error.Invalid_ID'), 'error')
    end

    local ped = GetPlayerPed(source)
    local targetPed = GetPlayerPed(buyerId)
    if targetPed == 0 then
        return exports.qbx_core:Notify(source, locale('error.buyerinfo'), 'error')
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return exports.qbx_core:Notify(source, locale('error.notinveh'), 'error')
    end

    local vehicleId = Entity(vehicle).state.vehicleid or qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(vehicle))
    if not vehicleId then
        return exports.qbx_core:Notify(source, locale('error.notowned'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(source)
    local target = exports.qbx_core:GetPlayer(buyerId)
    local row = qbx_vehicles:GetPlayerVehicle(vehicleId)
    local isFinanced = financeStorage.fetchIsFinanced(vehicleId)

    if not row then return end

    if config.finance.preventSelling and isFinanced then
        return exports.qbx_core:Notify(source, locale('error.financed'), 'error')
    end

    if row.citizenid ~= player.PlayerData.citizenid then
        return exports.qbx_core:Notify(source, locale('error.notown'), 'error')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0 then
        return exports.qbx_core:Notify(source, locale('error.playertoofar'), 'error')
    end

    local targetcid = target.PlayerData.citizenid
    if not target then
        return exports.qbx_core:Notify(source, locale('error.buyerinfo'), 'error')
    end

    saleTimeout[source] = true

    SetTimeout(config.saleTimeout, function()
        saleTimeout[source] = false
    end)

    if isFinanced then
        local financeData = financeStorage.fetchFinancedVehicleEntityById(vehicleId)
        local confirmFinance = lib.callback.await('qbx_vehicleshop:client:confirmFinance', buyerId, financeData)
        if not confirmFinance then
            return exports.qbx_core:Notify(source, locale('error.buyerdeclined'), 'error')
        end
    end

    lib.callback('qbx_vehicleshop:client:confirmTrade', buyerId, function(approved)
        if not approved then
            exports.qbx_core:Notify(source, locale('error.buyerdeclined'), 'error')
            return
        end

        if sellAmount > 0 then
            local currencyType = findChargeableCurrencyType(sellAmount, target.PlayerData.money.cash, target.PlayerData.money.bank)

            if not currencyType then
                return exports.qbx_core:Notify(source, locale('error.buyertoopoor'), 'error')
            end

            player.Functions.AddMoney(currencyType, sellAmount)
            target.Functions.RemoveMoney(currencyType, sellAmount)
        end

        qbx_vehicles:SetPlayerVehicleOwner(row.id, targetcid)
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, row.props.plate)

        local sellerMessage = sellAmount > 0 and locale('success.soldfor') .. lib.math.groupdigits(sellAmount) or locale('success.gifted')
        local buyerMessage = sellAmount > 0 and locale('success.boughtfor') .. lib.math.groupdigits(sellAmount) or locale('success.received_gift')

        exports.qbx_core:Notify(source, sellerMessage, 'success')
        exports.qbx_core:Notify(buyerId, buyerMessage, 'success')
        if isFinanced then
            financeTimer[buyerId].hasFinanced = true
        end
    end, GetEntityModel(vehicle), sellAmount)
end)

---@param vehicleId integer
---@return boolean
local function isFinanced(vehicleId)
    return financeStorage.fetchIsFinanced(vehicleId)
end

exports('IsFinanced', isFinanced)

---@param shopShape vector3[]
---@param shopName string
local function createShop(shopShape, shopName)
    return lib.zones.poly({
        name = shopName,
        points = shopShape,
        thickness = 5,
    })
end

-- Create shop zones for point checking
CreateThread(function()
    for shopName, shop in pairs(sharedConfig.shops) do
        shopZones[#shopZones + 1] = createShop(shop.zone.shape, shopName)
    end
end)
