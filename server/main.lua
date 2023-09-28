-- Variables
local financeTimer = {}
local coreVehicles = exports.qbx_core:GetVehiclesByName()

-- Handlers
-- Store game time for player when they load
RegisterNetEvent('qb-vehicleshop:server:addPlayer', function(citizenid)
    financeTimer[citizenid] = os.time()
end)

-- Deduct stored game time from player on logout
RegisterNetEvent('qb-vehicleshop:server:removePlayer', function(citizenid)
    if not financeTimer[citizenid] then return end

    local playTime = financeTimer[citizenid]
    local financetime = FetchVehicleEntitiesByCitizenId(citizenid)
    for _, v in pairs(financetime) do
        if v.balance >= 1 then
            local newTime = math.floor(v.financetime - (((os.time() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            UpdateVehicleEntityFinanceTime(newTime, v.plate)
        end
    end
    financeTimer[citizenid] = nil
end)

-- Deduct stored game time from player on quit because we can't get citizenid
AddEventHandler('playerDropped', function()
    local src = source
    local license = exports.qbx_core:GetIdentifier(src, 'license2') or exports.qbx_core:GetIdentifier(src, 'license')
    if not license then return end
    local vehicles = FetchVehicleEntitiesByLicense(license)
    if not vehicles then return end
    for _, v in pairs(vehicles) do
        local playTime = financeTimer[v.citizenid]
        if v.balance >= 1 and playTime then
            local newTime = math.floor(v.financetime - (((os.time() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            UpdateVehicleEntityFinanceTime(newTime, v.plate)
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
    return math.round(balance), math.round(vehPaymentAmount)
end

---@class FinancedVehicle
---@field vehiclePlate string
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
    return math.round(newBalance), math.round(newPayment), newPaymentsLeft
end

local function GeneratePlate()
    local plate
    repeat
        plate = GenerateRandomPlate('11AAA111')
    until not DoesVehicleEntityExist(plate)
    return plate:upper()
end

-- Callbacks

lib.callback.register('qb-vehicleshop:server:GetVehiclesByName', function(source)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    local vehicles = FetchVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    if vehicles[1] then
        return vehicles
    end
end)

lib.callback.register('qb-vehicleshop:server:spawnVehicle', function(source, model, coords, plate)
    local netId = SpawnVehicle(source, model, coords, true)
    if not netId or netId == 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    return netId
end)

-- Events

-- Brute force vehicle deletion
---@param netId number
RegisterNetEvent('qb-vehicleshop:server:deleteVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(vehicle)
end)

-- Sync vehicle for other players
---@param data unknown
RegisterNetEvent('qb-vehicleshop:server:swapVehicle', function(data)
    TriggerClientEvent('qb-vehicleshop:client:swapVehicle', -1, data)
end)

-- Send customer for test drive
RegisterNetEvent('qb-vehicleshop:server:customTestDrive', function(vehicle, playerId)
    local src = source
    local target = tonumber(playerId) --[[@as number]]
    if not exports.qbx_core:GetPlayer(target) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
        return
    end
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target))) < 3 then
        TriggerClientEvent('qb-vehicleshop:client:TestDrive', target, { vehicle = vehicle })
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
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
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
        return false
    end

    player.Functions.RemoveMoney(currencyType, amount)
    return true
end

-- Make a finance payment
RegisterNetEvent('qb-vehicleshop:server:financePayment', function(paymentAmount, vehData)
    local src = source
    local plate = vehData.vehiclePlate
    paymentAmount = tonumber(paymentAmount) --[[@as number]]
    local minPayment = tonumber(vehData.paymentAmount) --[[@as number]]
    local timer = (Config.PaymentInterval * 60)
    local newBalance, newPaymentsLeft, newPayment = calculateNewFinance(paymentAmount, vehData)

    if newBalance <= 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.overpaid'), 'error')
        return
    end

    if paymentAmount < minPayment then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.minimumallowed') .. CommaValue(minPayment), 'error')
        return
    end

    if not removeMoney(src, paymentAmount) then return end

    UpdateVehicleFinance({
        balance = newBalance,
        payment = newPayment,
        paymentsLeft = newPaymentsLeft,
        timer = timer
    }, plate)
end)


-- Pay off vehice in full
RegisterNetEvent('qb-vehicleshop:server:financePaymentFull', function(data)
    local src = source
    local vehBalance = data.vehBalance
    local vehPlate = data.vehPlate

    if vehBalance == 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.alreadypaid'), 'error')
        return
    end

    if not removeMoney(src, vehBalance) then return end

    UpdateVehicleFinance({
        balance = 0,
        payment = 0,
        paymentsLeft = 0,
        timer = 0,
    }, vehPlate)
end)

-- Buy public vehicle outright
RegisterNetEvent('qb-vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    vehicle = vehicle.buyVehicle
    local vehiclePrice = coreVehicles[vehicle].price
    local currencyType = findChargeableCurrencyType(vehiclePrice, player.PlayerData.money.cash, player.PlayerData.money.bank)
    if not currencyType then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
        return
    end

    local cid = player.PlayerData.citizenid
    local plate = GeneratePlate()
    InsertVehicleEntity({
        license = player.PlayerData.license,
        citizenId = cid,
        model = vehicle,
        plate = plate,
    })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchased'), 'success')
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
    player.Functions.RemoveMoney(currencyType, vehiclePrice, 'vehicle-bought-in-showroom')
end)

-- Finance public vehicle
RegisterNetEvent('qb-vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local vehiclePrice = coreVehicles[vehicle].price
    local minDown = tonumber(math.round((Config.MinimumDown / 100) * vehiclePrice)) --[[@as number]]
    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]

    if downPayment > vehiclePrice then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notworth'), 'error')
    end
    if downPayment < minDown then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.downtoosmall'), 'error')
    end
    if paymentAmount > Config.MaximumPayments then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.exceededmax'), 'error')
    end

    local currencyType = findChargeableCurrencyType(downPayment, player.PlayerData.money.cash, player.PlayerData.money.bank)

    if not currencyType then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
    end

    local plate = GeneratePlate()
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)
    local cid = player.PlayerData.citizenid
    local timer = (Config.PaymentInterval * 60)

    InsertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            license = player.PlayerData.license,
            citizenId = cid,
            model = vehicle,
            plate = plate,
        },
        vehicleFinance = {
            balance = balance,
            payment = vehPaymentAmount,
            paymentsLeft = paymentAmount,
            timer = timer,
        }
    })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchased'), 'success')
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
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
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
        return false
    end

    target.Functions.RemoveMoney(currencyType, downPayment, 'vehicle-bought-in-showroom')

    local commission = math.round(price * Config.Commission)
    player.Functions.AddMoney('bank', price * Config.Commission)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.earned_commission', {amount = CommaValue(commission)}), 'success')

    exports.qbx_management:AddMoney(player.PlayerData.job.name, price)
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, Lang:t('success.purchased'), 'success')
    return true
end

-- Sell vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellShowroomVehicle', function(data, playerid)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerid))

    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end

    local vehicle = data
    local vehiclePrice = coreVehicles[vehicle].price
    local cid = target.PlayerData.citizenid
    local plate = GeneratePlate()

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, vehiclePrice) then return end

    InsertVehicleEntity({
        license = target.PlayerData.license,
        citizenId = cid,
        model = vehicle,
        plate = plate
    })

    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
end)

-- Finance vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellfinanceVehicle', function(downPayment, paymentAmount, vehicle, playerid)
    local src = source
    local target = exports.qbx_core:GetPlayer(tonumber(playerid))

    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end

    downPayment = tonumber(downPayment) --[[@as number]]
    paymentAmount = tonumber(paymentAmount) --[[@as number]]
    local vehiclePrice = coreVehicles[vehicle].price
    local minDown = tonumber(math.round((Config.MinimumDown / 100) * vehiclePrice)) --[[@as number]]

    if downPayment > vehiclePrice then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notworth'), 'error')
    end
    if downPayment < minDown then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.downtoosmall'), 'error')
    end
    if paymentAmount > Config.MaximumPayments then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.exceededmax'), 'error')
    end

    local cid = target.PlayerData.citizenid
    local timer = (Config.PaymentInterval * 60)
    local plate = GeneratePlate()
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)

    if not sellShowroomVehicleTransact(src, target, vehiclePrice, downPayment) then return end

    InsertVehicleEntityWithFinance({
        insertVehicleEntityRequest = {
            license = target.PlayerData.license,
            citizenId = cid,
            model = vehicle,
            plate = plate,
        },
        vehicleFinance = {
            balance = balance,
            payment = vehPaymentAmount,
            paymentsLeft = paymentAmount,
            timer = timer,
        }
    })

    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
end)

-- Check if payment is due
RegisterNetEvent('qb-vehicleshop:server:checkFinance', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local result = FetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    if not result[1] then return end

    TriggerClientEvent('QBCore:Notify', src, Lang:t('general.paymentduein', {time = Config.PaymentWarning}))
    Wait(Config.PaymentWarning * 60000)
    local vehicles = FetchFinancedVehicleEntitiesByCitizenId(player.PlayerData.citizenid)
    for _, v in pairs(vehicles) do
        local plate = v.plate
        DeleteVehicleEntity(plate)
        --MySQL.update('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {'REPO-'..v.citizenid, plate}) -- Use this if you don't want them to be deleted
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.repossessed', {plate = plate}), 'error')
    end
end)

-- Transfer vehicle to player in passenger seat
lib.addCommand('transfervehicle', {help = Lang:t('general.command_transfervehicle'), params = {{name = 'id', type = 'playerId', help = Lang:t('general.command_transfervehicle_help')}, {name = 'amount', type = 'number', help = Lang:t('general.command_transfervehicle_amount')}}}, function(source, args)
    local src = source
    local buyerId = args.id
    local sellAmount = args.amount
    if buyerId == 0 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
    end
    local ped = GetPlayerPed(src)

    local targetPed = GetPlayerPed(buyerId)
    if targetPed == 0 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.buyerinfo'), 'error')
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notinveh'), 'error')
    end

    local plate = string.trim(GetVehicleNumberPlateText(vehicle))
    if not plate then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.vehinfo'), 'error')
    end

    local player = exports.qbx_core:GetPlayer(src)
    local target = exports.qbx_core:GetPlayer(buyerId)
    local row = FetchVehicleEntityByPlate(plate)
    if Config.PreventFinanceSelling and row.balance > 0 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.financed'), 'error')
    end
    if row.citizenid ~= player.PlayerData.citizenid then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notown'), 'error')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 5.0 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end
    local targetcid = target.PlayerData.citizenid
    local targetlicense = exports.qbx_core:GetIdentifier(target.PlayerData.source, 'license')
    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.buyerinfo'), 'error')
    end
    if not sellAmount then
        UpdateVehicleEntityOwner(targetcid, targetlicense, plate)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.gifted'), 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, plate)
        TriggerClientEvent('QBCore:Notify', buyerId, Lang:t('success.received_gift'), 'success')
        return
    end

    local currencyType = findChargeableCurrencyType(sellAmount, target.PlayerData.money.cash, target.PlayerData.money.bank)
    if not currencyType then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.buyertoopoor'), 'error')
    end

    UpdateVehicleEntityOwner(targetcid, targetlicense, plate)
    player.Functions.AddMoney(currencyType, sellAmount)
    target.Functions.RemoveMoney(currencyType, sellAmount)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.soldfor') .. CommaValue(sellAmount), 'success')
    TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, plate)
    TriggerClientEvent('QBCore:Notify', buyerId, Lang:t('success.boughtfor') .. CommaValue(sellAmount), 'success')
end)
