local config = require 'config.client'
local sharedConfig = require 'config.shared'
local vehiclesMenu, vehiclesMenuCount = require 'client.vehicles'
local VEHICLES = exports.qbx_core:GetVehiclesByName()
local VEHICLES_HASH = exports.qbx_core:GetVehiclesByHash()
local testDriveVeh = 0
local insideShop

---@param data VehicleFinanceClient
local function financePayment(data)
    local dialog = lib.inputDialog(locale('menus.veh_finance'), {
        {
            type = 'number',
            label = locale('menus.veh_finance_payment'),
        }
    })

    if not dialog then return end

    local paymentAmount = tonumber(dialog[1])
    TriggerServerEvent('qbx_vehicleshop:server:financePayment', paymentAmount, {
        vehId = data.vehId,
        paymentAmount = data.paymentAmount,
        balance = data.balance,
        paymentsLeft = data.paymentsLeft
    })
end

local function confirmationCheck()
    local alert = lib.alertDialog({
        header = 'Wait a minute!',
        content = 'Are you sure you wish to proceed?',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'No',
            confirm = 'Yes',
        }
    })

    return alert
end

---@param data VehicleFinanceClient
local function showVehicleFinanceMenu(data)
    local vehLabel = ('%s %s'):format(data.brand, data.name)
    local vehFinance = {
        {
            title = 'Finance Information',
            icon = 'circle-info',
            description = ('Name: %s\nPlate: %s\nRemaining Balance: $%s\nRecurring Payment Amount: $%s\nPayments Left: %s'):format(vehLabel, data.vehiclePlate, lib.math.groupdigits(data.balance), lib.math.groupdigits(data.paymentAmount), data.paymentsLeft),
            readOnly = true,
        },
        {
            title = locale('menus.veh_finance_pay'),
            onSelect = function()
                financePayment(data)
            end,
        },
        {
            title = locale('menus.veh_finance_payoff'),
            onSelect = function()
                local check = confirmationCheck()

                if check == 'confirm' then
                    TriggerServerEvent('qbx_vehicleshop:server:financePaymentFull', { vehBalance = data.balance, vehId = data.vehId })
                else
                    lib.showContext('vehicleFinance')
                end
            end,
        },
    }

    lib.registerContext({
        id = 'vehicleFinance',
        title = locale('menus.financed_header'),
        menu = 'ownedVehicles',
        options = vehFinance
    })

    lib.showContext('vehicleFinance')
end

--- Gets the owned vehicles based on financing then opens a menu
local function showFinancedVehiclesMenu()
    local vehicles = lib.callback.await('qbx_vehicleshop:server:GetVehiclesByName')
    local ownedVehicles = {}

    if not vehicles or #vehicles == 0 then
        return exports.qbx_core:Notify(locale('error.nofinanced'), 'error')
    end

    for _, v in pairs(vehicles) do
        if v.balance and v.balance > 0 then
            local plate = v.props.plate
            local vehicle = VEHICLES[v.modelName]

            plate = plate and plate:upper()

            ownedVehicles[#ownedVehicles + 1] = {
                title = vehicle.name,
                description = locale('menus.veh_platetxt')..plate,
                icon = 'fa-solid fa-car-side',
                arrow = true,
                onSelect = function()
                    showVehicleFinanceMenu({
                        vehId = v.id,
                        name = vehicle.name,
                        brand = vehicle.brand,
                        vehiclePlate = plate,
                        balance = v.balance,
                        paymentsLeft = v.paymentsleft,
                        paymentAmount = v.paymentamount
                    })
                end
            }
        end
    end

    if #ownedVehicles == 0 then
        return exports.qbx_core:Notify(locale('error.nofinanced'), 'error')
    end

    lib.registerContext({
        id = 'ownedVehicles',
        title = locale('menus.owned_vehicles_header'),
        options = ownedVehicles
    })

    lib.showContext('ownedVehicles')
end

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    local citizenId = QBX.PlayerData.citizenid
    TriggerServerEvent('qbx_vehicleshop:server:removePlayer', citizenId)
end)

--- Fetches the name of a vehicle from QB Shared
---@param closestVehicle integer
---@return string
local function getVehName(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return VEHICLES[vehicle].name
end

--- Fetches the price of a vehicle from QB Shared then it formats it into a text
---@param closestVehicle integer
---@return string
local function getVehPrice(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return lib.math.groupdigits(VEHICLES[vehicle].price)
end

--- Fetches the brand of a vehicle from QB Shared
---@param closestVehicle integer
---@return string
local function getVehBrand(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return VEHICLES[vehicle].brand
end

---@param targetShowroomVehicle integer vehicleName
---@param buyVehicle string model
local function openFinance(targetShowroomVehicle, buyVehicle)
    local title = ('%s %s - $%s'):format(VEHICLES[buyVehicle].brand:upper(), VEHICLES[buyVehicle].name:upper(), getVehPrice(targetShowroomVehicle))
    local dialog = lib.inputDialog(title, {
        {
            type = 'number',
            label = locale('menus.financesubmit_downpayment')..sharedConfig.finance.minimumDown..'%',
            min = VEHICLES[buyVehicle].price * sharedConfig.finance.minimumDown / 100,
            max = VEHICLES[buyVehicle].price
        },
        {
            type = 'number',
            label = locale('menus.financesubmit_totalpayment')..sharedConfig.finance.maximumPayments,
            min = 2,
            max = sharedConfig.finance.maximumPayments
        }
    })

    if not dialog then return end

    local downPayment = tonumber(dialog[1])
    local paymentAmount = tonumber(dialog[2])

    if not downPayment or not paymentAmount then return end

    TriggerServerEvent('qbx_vehicleshop:server:financeVehicle', downPayment, paymentAmount, buyVehicle)
end

--- Opens a menu with list of vehicles based on given category
---@param category string
---@param targetVehicle number
local function openVehCatsMenu(category, targetVehicle)

    local categoryMenu = {}
    for i = 1, vehiclesMenuCount do
        local vehicle = vehiclesMenu[i]
        if vehicle.category == category and vehicle.shopType == insideShop then
            vehicle.args.closestShop = insideShop
            vehicle.args.targetVehicle = targetVehicle
            categoryMenu[#categoryMenu + 1] = vehicle
        end
    end

    lib.registerContext({
        id = 'openVehCats',
        title = sharedConfig.shops[insideShop].categories[category],
        menu = 'vehicleCategories',
        options = categoryMenu
    })

    lib.showContext('openVehCats')
end

--- Opens a menu with list of vehicle categories
---@param args table<string, any>
local function openVehicleCategoryMenu(args)
    local categoryMenu = {}
    local sortedCategories = {}
    local categories = sharedConfig.shops[insideShop].categories

    for k, v in pairs(categories) do
        sortedCategories[#sortedCategories + 1] = {
            category = k,
            label = v
        }
    end

    table.sort(sortedCategories, function(a, b)
        return string.upper(a.label) < string.upper(b.label)
    end)

    for i = 1, #sortedCategories do
        categoryMenu[#categoryMenu + 1] = {
            title = sortedCategories[i].label,
            arrow = true,
            onSelect = function()
                openVehCatsMenu(sortedCategories[i].category, args.targetVehicle)
            end
        }
    end

    lib.registerContext({
        id = 'vehicleCategories',
        title = locale('menus.categories_header'),
        menu = 'vehicleMenu',
        options = categoryMenu
    })

    lib.showContext('vehicleCategories')
end

---@param targetVehicle integer
local function openCustomFinance(targetVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[targetVehicle].vehicle
    local title = ('%s %s - $%s'):format(getVehBrand(targetVehicle):upper(), vehicle:upper(), getVehPrice(targetVehicle))
    local dialog = lib.inputDialog(title, {
        {
            type = 'number',
            label = locale('menus.financesubmit_downpayment')..sharedConfig.finance.minimumDown..'%',
        },
        {
            type = 'number',
            label = locale('menus.financesubmit_totalpayment')..sharedConfig.finance.maximumPayments,
        },
        {
            type = 'number',
            label = locale('menus.submit_ID'),
        }
    })

    if not dialog then return end

    local downPayment = tonumber(dialog[1])
    local paymentAmount = tonumber(dialog[2])
    local playerid = tonumber(dialog[3])

    if not downPayment or not paymentAmount or not playerid then return end

    TriggerServerEvent('qbx_vehicleshop:server:sellfinanceVehicle', downPayment, paymentAmount, vehicle, playerid)
end

---prompt client for playerId of another player
---@param vehModel string
---@return number? playerId
local function getPlayerIdInput(vehModel)
    local dialog = lib.inputDialog(VEHICLES[vehModel].name, {
        {
            type = 'number',
            label = locale('menus.submit_ID'),
            placeholder = 1
        }
    })

    if not dialog then return end
    if not dialog[1] then return end

    return tonumber(dialog[1])
end

---@param vehModel string
local function startTestDrive(vehModel)
    local playerId = getPlayerIdInput(vehModel)

    TriggerServerEvent('qbx_vehicleshop:server:customTestDrive', vehModel, playerId)
end

---@param vehModel string
local function sellVehicle(vehModel)
    local playerId = getPlayerIdInput(vehModel)

    TriggerServerEvent('qbx_vehicleshop:server:sellShowroomVehicle', vehModel, playerId)
end

--- Opens the vehicle shop menu
---@param targetVehicle number
local function openVehicleSellMenu(targetVehicle)
    local options = {}
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[targetVehicle].vehicle
    local swapOption = {
        title = locale('menus.swap_header'),
        description = locale('menus.swap_txt'),
        onSelect = openVehicleCategoryMenu,
        args = {
            targetVehicle = targetVehicle
        },
        arrow = true
    }

    if sharedConfig.shops[insideShop].type == 'free-use' then
        if sharedConfig.enableTestDrive then
            options[#options + 1] = {
                title = locale('menus.test_header'),
                description = locale('menus.freeuse_test_txt'),
                event = 'qbx_vehicleshop:client:testDrive',
                args = {
                    vehicle = vehicle
                }
            }
        end

        if sharedConfig.enableFreeUseBuy then
            options[#options + 1] = {
                title = locale('menus.freeuse_buy_header'),
                description = locale('menus.freeuse_buy_txt'),
                serverEvent = 'qbx_vehicleshop:server:buyShowroomVehicle',
                args = {
                    buyVehicle = vehicle
                }
            }
        end

        if sharedConfig.finance.enable then
            options[#options + 1] = {
                title = locale('menus.finance_header'),
                description = locale('menus.freeuse_finance_txt'),
                onSelect = function()
                    openFinance(targetVehicle, vehicle)
                end
            }
        end

        options[#options + 1] = swapOption
    else
        options[1] = {
                title = locale('menus.managed_sell_header'),
                description = locale('menus.managed_sell_txt'),
                onSelect = function()
                    sellVehicle(vehicle)
                end,
        }

        if sharedConfig.enableTestDrive then
            options[#options + 1] = {
                title = locale('menus.test_header'),
                description = locale('menus.managed_test_txt'),
                onSelect = function()
                    startTestDrive(vehicle)
                end
            }
        end

        if sharedConfig.finance.enable then
            options[#options + 1] = {
                title = locale('menus.finance_header'),
                description = locale('menus.managed_finance_txt'),
                onSelect = function()
                    openCustomFinance(targetVehicle)
                end
            }
        end

        options[#options + 1] = swapOption
    end

    lib.registerContext({
        id = 'vehicleMenu',
        title = ('%s %s - $%s'):format(getVehBrand(targetVehicle):upper(), getVehName(targetVehicle):upper(), getVehPrice(targetVehicle)),
        options = options
    })

    lib.showContext('vehicleMenu')
end

--- End test drive
local function endTestDrive()
    TriggerServerEvent('qbx_vehicleshop:server:deleteVehicle', testDriveVeh)
    testDriveVeh = 0
    LocalPlayer.state:set('isInTestDrive', false, true)
    exports.qbx_core:Notify(locale('general.testdrive_complete'), 'success')
end
--- Starts the test drive timer based on time and shop
---@param time number
local function startTestDriveTimer(time)
    local gameTimer = GetGameTimer()
    local timeMs = time * 1000

    CreateThread(function()
        local playerState = LocalPlayer.state
        while playerState.isInTestDrive do
            local currentGameTime = GetGameTimer()
            local secondsLeft = currentGameTime - gameTimer

            if currentGameTime < gameTimer + timeMs and secondsLeft >= timeMs - 50 then
                endTestDrive()
            end

            qbx.drawText2d({
                text = locale('general.testdrive_timer')..math.ceil(time - secondsLeft / 1000),
                coords = vec2(1.0, 1.38),
                scale = 0.5
            })

            Wait(0)
        end
    end)
end

---@param shopName string
---@param entity number vehicle
---@param targetVehicle number
local function createVehicleTarget(shopName, entity, targetVehicle)
    local shop = sharedConfig.shops[shopName]

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'vehicleshop:showVehicleOptions',
            icon = 'fas fa-car',
            label = locale('general.vehinteraction'),
            distance = shop.zone.targetDistance,
            groups = shop.job,
            onSelect = function()
                openVehicleSellMenu(targetVehicle)
            end
        }
    })
end

---@param shopName string
---@param coords vector4
---@param targetVehicle number
local function createVehicleZone(shopName, coords, targetVehicle)
    local shop = sharedConfig.shops[shopName]

    lib.zones.box({
        coords = coords.xyz,
        size = shop.zone.size,
        rotation = coords.w,
        debug = config.debugPoly,
        onEnter = function()
            if not insideShop then return end

            local job = sharedConfig.shops[insideShop].job
            if job and QBX.PlayerData.job.name ~= job then return end

            lib.showTextUI(locale('menus.keypress_vehicleViewMenu'))
        end,
        inside = function()
            if not insideShop then return end

            local job = sharedConfig.shops[insideShop].job
            if not IsControlJustPressed(0, 38) or job and QBX.PlayerData.job.name ~= job then return end

            openVehicleSellMenu(targetVehicle)
        end,
        onExit = function()
            lib.hideTextUI()
        end
    })
end

--- Creates a shop
---@param shopShape vector3[]
---@param name string
local function createShop(shopShape, name)
    lib.zones.poly({
        name = name,
        points = shopShape,
        thickness = 5,
        debug = config.debugPoly,
        onEnter = function(self)
            insideShop = self.name
        end,
        onExit = function()
            insideShop = nil
        end,
    })
end

---@param model string
---@param coords vector4
---@return number vehicleEntity
local function createShowroomVehicle(model, coords)
    lib.requestModel(model, 10000)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, false, false)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(veh)
    SetEntityInvincible(veh, true)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleDoorsLocked(veh, 3)
    FreezeEntityPosition(veh, true)
    SetVehicleNumberPlateText(veh, 'BUY ME')

    return veh
end

--- Initial function to set things up. Creating vehicleshops defined in the config and spawns the sellable vehicles
local shopVehs = {}

local function init()
    CreateThread(function()
        if sharedConfig.finance.enable then
            lib.zones.box({
                coords = sharedConfig.finance.zone,
                size = vec3(2, 2, 4),
                rotation = 0,
                debug = config.debugPoly,
                onEnter = function()
                    lib.showTextUI(locale('menus.keypress_showFinanceMenu'))
                end,
                inside = function()
                    if IsControlJustPressed(0, 38) then
                        showFinancedVehiclesMenu()
                    end
                end,
                onExit = function()
                    lib.hideTextUI()
                end
            })
        end
    end)

    CreateThread(function()
        for shopName, shop in pairs(sharedConfig.shops) do
            createShop(shop.zone.shape, shopName)

            local showroomVehicles = sharedConfig.shops[shopName].showroomVehicles
            for i = 1, #showroomVehicles do
                local showroomVehicle = showroomVehicles[i]
                local veh = createShowroomVehicle(showroomVehicle.vehicle, showroomVehicle.coords)

                shopVehs[i] = veh

                if config.useTarget then
                    createVehicleTarget(shopName, veh, i)
                else
                    createVehicleZone(shopName, showroomVehicle.coords, i)
                end
            end
        end
    end)
end

--- Executes once player fully loads in
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local citizenId = QBX.PlayerData.citizenid
    TriggerServerEvent('qbx_vehicleshop:server:addPlayer', citizenId)
    TriggerServerEvent('qbx_vehicleshop:server:checkFinance')
    init()
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    for i = 1, #shopVehs do
        DeleteEntity(shopVehs[i])
    end

    shopVehs = {}
end)

--- Starts the test drive. If vehicle parameter is not provided then the test drive will start with the closest vehicle to the player.
--- @param args table
RegisterNetEvent('qbx_vehicleshop:client:testDrive', function(args)
    if LocalPlayer.state.isInTestDrive then
        exports.qbx_core:Notify(locale('error.testdrive_alreadyin'), 'error')
        return
    end

    if not args then return end

    LocalPlayer.state:set('isInTestDrive', true, true)
    local testDrive = sharedConfig.shops[insideShop].testDrive
    local plate = 'TEST'..lib.string.random('1111')
    local netId = lib.callback.await('qbx_vehicleshop:server:spawnVehicle', false, {
        modelName = args.vehicle,
        coords = testDrive.spawn,
        plate = plate
    })

    lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            return true
        end
    end, 'netId not exist')

    testDriveVeh = netId
    exports.qbx_core:Notify(locale('general.testdrive_timenoti', testDrive.limit), 'inform')
    startTestDriveTimer(testDrive.limit * 60)
end)

--- Swaps the chosen vehicle with another one
---@param data {toVehicle: string, targetVehicle: integer, closestShop: string}
RegisterNetEvent('qbx_vehicleshop:client:swapVehicle', function(data)
    local shopName = data.closestShop
    local dataTargetVehicle = sharedConfig.shops[shopName].showroomVehicles[data.targetVehicle]
    if dataTargetVehicle.vehicle == data.toVehicle then return end

    local closestVehicle = lib.getClosestVehicle(dataTargetVehicle.coords.xyz, 5, false)
    if not closestVehicle then return end

    if not IsModelInCdimage(data.toVehicle) then
        lib.print.error(('Failed to find model for "%s". Vehicle might not be streamed?'):format(data.toVehicle))
        return
    end

    DeleteEntity(closestVehicle)
    while DoesEntityExist(closestVehicle) do
        Wait(50)
    end

    local veh = createShowroomVehicle(data.toVehicle, dataTargetVehicle.coords)

    dataTargetVehicle.vehicle = data.toVehicle

    if config.useTarget then
        createVehicleTarget(shopName, veh, data.targetVehicle)
    end
end)

local function confirmTrade(confirmationText)
    local accepted

    exports.npwd:createSystemNotification({
        uniqId = "vehicleShop:confirmTrade",
        content = confirmationText,
        secondary = "Confirm Trade",
        keepOpen = true,
        duration = 10000,
        controls = true,
        onConfirm = function()
            accepted = true
        end,
        onCancel = function()
            accepted = false
        end,
    })

    while not accepted do
        Wait(100)
    end

    return accepted
end

lib.callback.register('qbx_vehicleshop:client:confirmTrade', function(vehicle, sellAmount)
    local confirmationText = locale('general.transfervehicle_confirm', VEHICLES_HASH[vehicle].brand, VEHICLES_HASH[vehicle].name, lib.math.groupdigits(sellAmount) or 0)

    if GetResourceState('npwd') ~= 'started' then
        local input = lib.inputDialog(confirmationText, {
            {
                type = 'checkbox',
                label = 'Confirm'
            },
        })
        return input?[1]
    end

    return confirmTrade(confirmationText)
end)

--- Thread to create blips
CreateThread(function()
    for _, v in pairs(sharedConfig.shops) do
        local blip = v.blip
        if blip.show then
            local dealer = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
            SetBlipSprite(dealer, blip.sprite)
            SetBlipDisplay(dealer, 4)
            SetBlipScale(dealer, 0.70)
            SetBlipAsShortRange(dealer, true)
            SetBlipColour(dealer, blip.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(blip.label)
            EndTextCommandSetBlipName(dealer)
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= cache.resource then return end

    init()
end)