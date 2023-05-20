-- Variables
local QBCore = exports['qbx-core']:GetCoreObject()
local financetimer = {}

-- Handlers
-- Store game time for player when they load
RegisterNetEvent('qb-vehicleshop:server:addPlayer', function(citizenid, gameTime)
    financetimer[citizenid] = gameTime
end)

-- Deduct stored game time from player on logout
RegisterNetEvent('qb-vehicleshop:server:removePlayer', function(citizenid)
    if not financetimer[citizenid] then return end
    
    local playTime = financetimer[citizenid]
    local financetime = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenid})
    for _, v in pairs(financetime) do
        if v.balance >= 1 then
            local newTime = math.floor(v.financetime - (((GetGameTimer() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            MySQL.update('UPDATE player_vehicles SET financetime = ? WHERE plate = ?', {newTime, v.plate})
        end
    end
    financetimer[citizenid] = nil
end)

-- Deduct stored game time from player on quit because we can't get citizenid
AddEventHandler('playerDropped', function()
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license2') or QBCore.Functions.GetIdentifier(src, 'license')
    if not license then return end
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE license = ?', {license})
    if not vehicles then return end
    for _, v in pairs(vehicles) do
        local playTime = financetimer[v.citizenid]
        if v.balance >= 1 and playTime then
            local newTime = math.floor(v.financetime - (((GetGameTimer() - playTime) / 1000) / 60))
            if newTime < 0 then newTime = 0 end
            MySQL.update('UPDATE player_vehicles SET financetime = ? WHERE plate = ?', {newTime, v.plate})
        end
    end
    if vehicles[1] and financetimer[vehicles[1].citizenid] then
        financetimer[vehicles[1].citizenid] = nil
    end
end)

-- Functions

---Rounds both positive and negative numbers to the nearest whole number.
---@param x number
---@return integer
local function round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

---@param vehiclePrice number
---@param downPayment number
---@param paymentamount number
---@return integer balance owed on the vehicle
---@return integer numPayments to pay off the balance
local function calculateFinance(vehiclePrice, downPayment, paymentamount)
    local balance = vehiclePrice - downPayment
    local vehPaymentAmount = balance / paymentamount
    return round(balance), round(vehPaymentAmount)
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
    local newBalance = tonumber(vehData.balance - paymentAmount)
    local minusPayment = vehData.paymentsLeft - 1
    local newPaymentsLeft = newBalance / minusPayment
    local newPayment = newBalance / newPaymentsLeft
    return round(newBalance), round(newPayment), newPaymentsLeft
end

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

---@param amount number
---@return string
local function comma_value(amount)
    local formatted = amount
    local k
    repeat
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
    until k == 0
    return formatted
end

---@param source number
---@return table? playerVehicle
lib.callback.register('qb-vehicleshop:server:getVehicles', function(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {player.PlayerData.citizenid})
    if vehicles[1] then
        return vehicles
    end
end)

-- Events

-- Brute force vehicle deletion
---@param netId number
RegisterNetEvent('qb-vehicleshop:server:deleteVehicle', function (netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(vehicle)
end)

-- Sync vehicle for other players
---@param data unknown
RegisterNetEvent('qb-vehicleshop:server:swapVehicle', function(data)
    local src = source
    TriggerClientEvent('qb-vehicleshop:client:swapVehicle', -1, data)
    Wait(1500)-- let new car spawn
    TriggerClientEvent('qb-vehicleshop:client:homeMenu', src)-- reopen main menu
end)

-- Send customer for test drive
RegisterNetEvent('qb-vehicleshop:server:customTestDrive', function(vehicle, playerid)
    local src = source
    local target = tonumber(playerid)
    if not QBCore.Functions.GetPlayer(target) then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
        return
    end
    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target))) < 3 then
        TriggerClientEvent('qb-vehicleshop:client:TestDrive', target, vehicle)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end
end)

-- Make a finance payment
RegisterNetEvent('qb-vehicleshop:server:financePayment', function(paymentAmount, vehData)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local plate = vehData.vehiclePlate
    paymentAmount = tonumber(paymentAmount)
    local minPayment = tonumber(vehData.paymentAmount)
    local timer = (Config.PaymentInterval * 60)
    local newBalance, newPaymentsLeft, newPayment = calculateNewFinance(paymentAmount, vehData)
    
    if newBalance <= 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.overpaid'), 'error')
        return
    end

    if not player or paymentAmount < minPayment then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.minimumallowed') .. comma_value(minPayment), 'error')
        return
    end

    if cash >= paymentAmount then
        player.Functions.RemoveMoney('cash', paymentAmount)
        MySQL.update('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {newBalance, newPayment, newPaymentsLeft, timer, plate})
    elseif bank >= paymentAmount then
        player.Functions.RemoveMoney('bank', paymentAmount)
        MySQL.update('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {newBalance, newPayment, newPaymentsLeft, timer, plate})
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
    end
end)


-- Pay off vehice in full
RegisterNetEvent('qb-vehicleshop:server:financePaymentFull', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cash = player.PlayerData.money.cash
    local bank = player.PlayerData.money.bank
    local vehBalance = data.vehBalance
    local vehPlate = data.vehPlate

    if not player or vehBalance == 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.alreadypaid'), 'error')
        return
    end

    if cash >= vehBalance then
        player.Functions.RemoveMoney('cash', vehBalance)
        MySQL.update('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {0, 0, 0, 0, vehPlate})
    elseif bank >= vehBalance then
        player.Functions.RemoveMoney('bank', vehBalance)
        MySQL.update('UPDATE player_vehicles SET balance = ?, paymentamount = ?, paymentsleft = ?, financetime = ? WHERE plate = ?', {0, 0, 0, 0, vehPlate})
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
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

-- Buy public vehicle outright
RegisterNetEvent('qb-vehicleshop:server:buyShowroomVehicle', function(vehicle)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    vehicle = vehicle.buyVehicle
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle].price
    local currencyType = findChargeableCurrencyType(vehiclePrice, player.PlayerData.money.cash, player.PlayerData.money.bank)
    if not currencyType then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
        return
    end

    local cid = player.PlayerData.citizenid
    local plate = GeneratePlate()
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        player.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        'pillboxgarage',
        0
    })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchased'), 'success')
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
    player.Functions.RemoveMoney(currencyType, vehiclePrice, 'vehicle-bought-in-showroom')
end)

-- Finance public vehicle
RegisterNetEvent('qb-vehicleshop:server:financeVehicle', function(downPayment, paymentAmount, vehicle)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle].price
    local minDown = tonumber(round((Config.MinimumDown / 100) * vehiclePrice))
    downPayment = tonumber(downPayment)
    paymentAmount = tonumber(paymentAmount)

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
    
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        pData.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        'pillboxgarage',
        0,
        balance,
        vehPaymentAmount,
        paymentAmount,
        timer
    })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.purchased'), 'success')
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', src, vehicle, plate)
    pData.Functions.RemoveMoney(currencyType, downPayment, 'vehicle-bought-in-showroom')
end)

-- Sell vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellShowroomVehicle', function(data, playerid)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(tonumber(playerid))

    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end

    local vehicle = data
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
    local currencyType = findChargeableCurrencyType(vehiclePrice, target.PlayerData.money['cash'], target.PlayerData.money['bank'])

    if not currencyType then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
    end

    local cid = target.PlayerData.citizenid
    local commission = round(vehiclePrice * Config.Commission)
    local plate = GeneratePlate()

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        target.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        'pillboxgarage',
        0
    })
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
    target.Functions.RemoveMoney(currencyType, vehiclePrice, 'vehicle-bought-in-showroom')
    player.Functions.AddMoney('bank', commission)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.earned_commission', {amount = comma_value(commission)}), 'success')
    exports['qbx-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, Lang:t('success.purchased'), 'success')
end)

-- Finance vehicle to customer
RegisterNetEvent('qb-vehicleshop:server:sellfinanceVehicle', function(downPayment, paymentAmount, vehicle, playerid)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(tonumber(playerid))

    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.Invalid_ID'), 'error')
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target.PlayerData.source))) >= 3 then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.playertoofar'), 'error')
    end

    downPayment = tonumber(downPayment)
    paymentAmount = tonumber(paymentAmount)
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
    local minDown = tonumber(round((Config.MinimumDown / 100) * vehiclePrice))

    if downPayment > vehiclePrice then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notworth'), 'error')
    end
    if downPayment < minDown then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.downtoosmall'), 'error')
    end
    if paymentAmount > Config.MaximumPayments then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.exceededmax'), 'error')
    end

    local currencyType = findChargeableCurrencyType(downPayment, target.PlayerData.money['cash'], target.PlayerData.money['bank'])

    if not currencyType then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.notenoughmoney'), 'error')
    end

    local cid = target.PlayerData.citizenid
    local timer = (Config.PaymentInterval * 60)
    local commission = round(vehiclePrice * Config.Commission)
    local plate = GeneratePlate()
    local balance, vehPaymentAmount = calculateFinance(vehiclePrice, downPayment, paymentAmount)

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, balance, paymentamount, paymentsleft, financetime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        target.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        'pillboxgarage',
        0,
        balance,
        vehPaymentAmount,
        paymentAmount,
        timer
    })
    TriggerClientEvent('qb-vehicleshop:client:buyShowroomVehicle', target.PlayerData.source, vehicle, plate)
    target.Functions.RemoveMoney(currencyType, downPayment, 'vehicle-bought-in-showroom')
    player.Functions.AddMoney('bank', commission)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.earned_commission', {amount = comma_value(commission)}), 'success')
    exports['qbx-management']:AddMoney(player.PlayerData.job.name, vehiclePrice)
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, Lang:t('success.purchased'), 'success')
end)

-- Check if payment is due
RegisterNetEvent('qb-vehicleshop:server:checkFinance', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local query = 'SELECT * FROM player_vehicles WHERE citizenid = ? AND balance > 0 AND financetime < 1'
    local result = MySQL.query.await(query, {player.PlayerData.citizenid})
    if not result[1] then return end
    
    TriggerClientEvent('QBCore:Notify', src, Lang:t('general.paymentduein', {time = Config.PaymentWarning}))
    Wait(Config.PaymentWarning * 60000)
    local vehicles = MySQL.query.await(query, {player.PlayerData.citizenid})
    for _, v in pairs(vehicles) do
        local plate = v.plate
        MySQL.query('DELETE FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate})
        --MySQL.update('UPDATE player_vehicles SET citizenid = ? WHERE plate = ?', {'REPO-'..v.citizenid, plate}) -- Use this if you don't want them to be deleted
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.repossessed', {plate = plate}), 'error')
    end
end)

-- Transfer vehicle to player in passenger seat
QBCore.Commands.Add('transfervehicle', Lang:t('general.command_transfervehicle'), {{name = 'ID', help = Lang:t('general.command_transfervehicle_help')}, {name = 'amount', help = Lang:t('general.command_transfervehicle_amount')}}, false, function(source, args)
    local src = source
    local buyerId = tonumber(args[1])
    local sellAmount = tonumber(args[2])
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

    local plate = QBCore.Shared.Trim(GetVehicleNumberPlateText(vehicle))
    if not plate then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.vehinfo'), 'error')
    end

    local player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(buyerId)
    local row = MySQL.single.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
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
    local targetlicense = QBCore.Functions.GetIdentifier(target.PlayerData.source, 'license')
    if not target then
        return TriggerClientEvent('QBCore:Notify', src, Lang:t('error.buyerinfo'), 'error')
    end
    if not sellAmount then
        MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?', {targetcid, targetlicense, plate})
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.gifted'), 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, plate)
        TriggerClientEvent('QBCore:Notify', buyerId, Lang:t('success.received_gift'), 'success')
        return
    end
    if target.Functions.GetMoney('cash') > sellAmount then
        MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?', {targetcid, targetlicense, plate})
        player.Functions.AddMoney('cash', sellAmount)
        target.Functions.RemoveMoney('cash', sellAmount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.soldfor') .. comma_value(sellAmount), 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, plate)
        TriggerClientEvent('QBCore:Notify', buyerId, Lang:t('success.boughtfor') .. comma_value(sellAmount), 'success')
    elseif target.Functions.GetMoney('bank') > sellAmount then
        MySQL.update('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?', {targetcid, targetlicense, plate})
        player.Functions.AddMoney('bank', sellAmount)
        target.Functions.RemoveMoney('bank', sellAmount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.soldfor') .. comma_value(sellAmount), 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', buyerId, plate)
        TriggerClientEvent('QBCore:Notify', buyerId, Lang:t('success.boughtfor') .. comma_value(sellAmount), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.buyertoopoor'), 'error')
    end
end)
