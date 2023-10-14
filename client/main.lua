local testDriveVeh = 0
local inTestDrive = false
local insideShop = nil
local coreVehicles = exports.qbx_core:GetVehiclesByName()

---@class VehicleFinanceClient
---@field vehiclePlate string
---@field balance number
---@field paymentsLeft integer
---@field paymentAmount number

---@param data VehicleFinanceClient
local function financePayment(data)
    local dialog = lib.inputDialog(Lang:t('menus.veh_finance'), {
        {
            type = 'number',
            label = Lang:t('menus.veh_finance_payment'),
        }
    })

    if not dialog then return end

    local paymentAmount = tonumber(dialog[1])
    TriggerServerEvent('qb-vehicleshop:server:financePayment', paymentAmount, data)
end

---@param data VehicleFinanceClient
local function showVehicleFinanceMenu(data)
    local vehFinance = {
        {
            title = Lang:t('menus.veh_finance_balance'),
            description = Lang:t('menus.veh_finance_currency') .. CommaValue(data.balance)
        },
        {
            title = Lang:t('menus.veh_finance_total'),
            description = data.paymentsLeft
        },
        {
            title = Lang:t('menus.veh_finance_reccuring'),
            description = Lang:t('menus.veh_finance_currency') .. CommaValue(data.paymentAmount)
        },
        {
            title = Lang:t('menus.veh_finance_pay'),
            onSelect = function()
                financePayment(data)
            end,
        },
        {
            title = Lang:t('menus.veh_finance_payoff'),
            serverEvent = 'qb-vehicleshop:server:financePaymentFull',
            args = {
                vehBalance = data.balance,
                vehPlate = data.vehiclePlate
            }
        },
    }

    lib.registerContext({
        id = 'vehFinance',
        title = Lang:t('menus.financed_header'),
        menu = 'owned_vehicles',
        options = vehFinance
    })

    lib.showContext('vehFinance')
end

--- Gets the owned vehicles based on financing then opens a menu
local function showFinancedVehiclesMenu()
    local vehicles = lib.callback.await('qb-vehicleshop:server:GetVehiclesByName')
    local ownedVehicles = {}

    if vehicles == nil or #vehicles == 0 then return exports.qbx_core:Notify(Lang:t('error.nofinanced'), 'error') end
    for _, v in pairs(vehicles) do
        if v.balance ~= 0 then
            local name = coreVehicles[v.vehicle].name
            local plate = v.plate:upper()
            ownedVehicles[#ownedVehicles + 1] = {
                title = name,
                description = Lang:t('menus.veh_platetxt') .. plate,
                icon = "fa-solid fa-car-side",
                arrow = true,
                onSelect = function()
                    showVehicleFinanceMenu({
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
        return exports.qbx_core:Notify(Lang:t('error.nofinanced'), 'error')
    end

    lib.registerContext({
        id = 'owned_vehicles',
        title = Lang:t('menus.owned_vehicles_header'),
        options = ownedVehicles
    })
    lib.showContext('owned_vehicles')
end

lib.registerContext({
    id = 'fin_header_menu',
    title = Lang:t('menus.financed_header'),
    options = {
        {
            title = Lang:t('menus.finance_txt'),
            onSelect = showFinancedVehiclesMenu
        }
    }
})

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    local citizenid = QBX.PlayerData.citizenid
    TriggerServerEvent('qb-vehicleshop:server:removePlayer', citizenid)
end)

--- Fetches the name of a vehicle from QB Shared
---@param closestVehicle integer
---@return string
local function getVehName(closestVehicle)
    return coreVehicles[Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle].name
end

--- Fetches the price of a vehicle from QB Shared then it formats it into a text
---@param closestVehicle integer
---@return string
local function getVehPrice(closestVehicle)
    return CommaValue(coreVehicles[Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle].price)
end

--- Fetches the brand of a vehicle from QB Shared
---@param closestVehicle integer
---@return string
local function getVehBrand(closestVehicle)
    return coreVehicles[Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle].brand
end

--- based on which vehicleshop player is in
---@return integer index
local function getClosestShowroomVehicle()
    local pos = GetEntityCoords(cache.ped, true)
    local current = nil
    local dist = nil
    local closestShop = insideShop
    local showroomVehicles = Config.Shops[closestShop].ShowroomVehicles
    for id in pairs(showroomVehicles) do
        local dist2 = #(pos - showroomVehicles[id].coords.xyz)
        if not current or dist2 < dist then
            current = id
            dist = dist2
        end
    end
    return current
end

---@param closestShowroomVehicle integer vehicleName
---@param buyVehicle string model
local function openFinance(closestShowroomVehicle, buyVehicle)
    local dialog = lib.inputDialog(coreVehicles[buyVehicle].name:upper() .. ' ' .. buyVehicle:upper() .. ' - $' .. getVehPrice(closestShowroomVehicle), {
        {
            type = 'number',
            label = Lang:t('menus.financesubmit_downpayment') .. Config.MinimumDown .. '%',
        },
        {
            type = 'number',
            label = Lang:t('menus.financesubmit_totalpayment') .. Config.MaximumPayments,
        }
    })

    if not dialog then return end

    local downPayment = tonumber(dialog[1])
    local paymentAmount = tonumber(dialog[2])

    if not downPayment or not paymentAmount then return end

    TriggerServerEvent('qb-vehicleshop:server:financeVehicle', downPayment, paymentAmount, buyVehicle)
end

--- Opens a menu with list of vehicles based on given category
---@param category string
local function openVehCatsMenu(category)
    local vehMenu = {}
    local closestVehicle = getClosestShowroomVehicle()

    for k, v in pairs(coreVehicles) do
        if coreVehicles[k].category == category then
            if type(Config.Vehicles[k].shop) == 'table' then
                for _, shop in pairs(Config.Vehicles[k].shop) do
                    if shop == insideShop then
                        vehMenu[#vehMenu + 1] = {
                            title = v.brand..' '..v.name,
                            description = Lang:t('menus.veh_price') .. v.price,
                            serverEvent = 'qb-vehicleshop:server:swapVehicle',
                            args = {
                                toVehicle = v.model,
                                ClosestVehicle = closestVehicle,
                                ClosestShop = insideShop
                            }
                        }
                    end
                end
            elseif Config.Vehicles[k].shop == insideShop then
                vehMenu[#vehMenu + 1] = {
                    title = v.brand..' '..v.name,
                    description = Lang:t('menus.veh_price') .. v.price,
                    serverEvent = 'qb-vehicleshop:server:swapVehicle',
                    args = {
                        toVehicle = v.model,
                        ClosestVehicle = closestVehicle,
                        ClosestShop = insideShop
                    }
                }
            end
        end
    end

    lib.registerContext({
        id = 'open_veh_cats',
        title = Lang:t('menus.categories_header'),
        menu = 'vehicleCategories',
        options = vehMenu
    })

    lib.showContext('open_veh_cats')
end

--- Opens a menu with list of vehicle categories
local function openVehicleCategoryMenu()
    local categoryMenu = {}
    for k, v in pairs(Config.Shops[insideShop].Categories) do
        categoryMenu[#categoryMenu + 1] = {
            title = v,
            arrow = true,
            onSelect = function()
                openVehCatsMenu(k)
            end
        }
    end

    lib.registerContext({
        id = 'vehicleCategories',
        title = Lang:t('menus.categories_header'),
        menu = 'veh_menu',
        options = categoryMenu
    })

    lib.showContext('vehicleCategories')
end

---@param closestVehicle integer
local function openCustomFinance(closestVehicle)
    exports.scully_emotemenu:playEmoteByCommand('tablet2')

    local vehicle = Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle
    local dialog = lib.inputDialog(getVehBrand(closestVehicle):upper() .. ' ' .. vehicle:upper() .. ' - $' .. getVehPrice(closestVehicle), {
        {
            type = 'number',
            label = Lang:t('menus.financesubmit_downpayment') .. Config.MinimumDown .. '%',
        },
        {
            type = 'number',
            label = Lang:t('menus.financesubmit_totalpayment') .. Config.MaximumPayments,
        },
        {
            type = 'number',
            label = Lang:t('menus.submit_ID'),
        }
    })

    if not dialog then return end

    local downPayment = tonumber(dialog[1])
    local paymentAmount = tonumber(dialog[2])
    local playerid = tonumber(dialog[3])

    if not downPayment or not paymentAmount or not playerid then return end

    exports.scully_emotemenu:cancelEmote()
    TriggerServerEvent('qb-vehicleshop:server:sellfinanceVehicle', downPayment, paymentAmount,
        vehicle, playerid)
end

---prompt client for playerId of another player
---@param vehModel string
---@return number? playerId
local function getPlayerIdInput(vehModel)
    local dialog = lib.inputDialog(coreVehicles[vehModel].name, {
        {
            type = 'number',
            label = Lang:t('menus.submit_ID'),
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
    TriggerServerEvent('qb-vehicleshop:server:customTestDrive', vehModel, playerId)
end

---@param vehModel string
local function sellVehicle(vehModel)
    local playerId = getPlayerIdInput(vehModel)
    TriggerServerEvent('qb-vehicleshop:server:sellShowroomVehicle', vehModel, playerId)
end

--- Opens the vehicle shop menu
local function openVehicleSellMenu()
    local closestVehicle = getClosestShowroomVehicle()
    local options
    local swapOption = {
        title = Lang:t('menus.swap_header'),
        description = Lang:t('menus.swap_txt'),
        onSelect = openVehicleCategoryMenu,
        arrow = true
    }
    if Config.Shops[insideShop].Type == 'free-use' then
        options = {
            {
                title = Lang:t('menus.test_header'),
                description = Lang:t('menus.freeuse_test_txt'),
                event = 'qb-vehicleshop:client:TestDrive',
                args = {
                    vehicle = Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle
                }
            }
        }

        if Config.EnableFreeUseBuy then
            options[#options + 1] = {
                title = Lang:t('menus.freeuse_buy_header'),
                description = Lang:t('menus.freeuse_buy_txt'),
                serverEvent = 'qb-vehicleshop:server:buyShowroomVehicle',
                args = {
                    buyVehicle = Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle
                }
            }
        end

        if Config.EnableFinance then
            options[#options + 1] = {
                title = Lang:t('menus.finance_header'),
                description = Lang:t('menus.freeuse_finance_txt'),
                onSelect = function()
                    openFinance(closestVehicle, Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle)
                end
            }
        end

        options[#options + 1] = swapOption
    else
        options = {
            {
                title = Lang:t('menus.test_header'),
                description = Lang:t('menus.managed_test_txt'),
                onSelect = function()
                    startTestDrive(Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle)
                end,
            },
            {
                title = Lang:t('menus.managed_sell_header'),
                description = Lang:t('menus.managed_sell_txt'),
                onSelect = function()
                    sellVehicle(Config.Shops[insideShop].ShowroomVehicles[closestVehicle].chosenVehicle)
                end,
            }
        }

        if Config.EnableFinance then
            options[#options + 1] = {
                title = Lang:t('menus.finance_header'),
                description = Lang:t('menus.managed_finance_txt'),
                onSelect = function()
                    openCustomFinance(closestVehicle)
                end
            }
        end

        options[#options + 1] = swapOption
    end

    lib.registerContext({
        id = 'veh_menu',
        title = getVehBrand(closestVehicle):upper() .. ' ' .. getVehName(closestVehicle):upper() .. ' - $' .. getVehPrice(closestVehicle),
        options = options
    })
    lib.showContext('veh_menu')
end

--- Starts the test drive timer based on time and shop
---@param time number
---@param shop string
local function startTestDriveTimer(time, shop)
    local gameTimer = GetGameTimer()
    local timeMs = time * 1000

    CreateThread(function()
        while inTestDrive do
            local currentGameTime = GetGameTimer()
            local secondsLeft = currentGameTime - gameTimer
            if currentGameTime < gameTimer + timeMs then
                if secondsLeft >= timeMs - 50 then
                    TriggerServerEvent('qb-vehicleshop:server:deleteVehicle', testDriveVeh)
                    testDriveVeh = 0
                    inTestDrive = false
                    SetEntityCoords(cache.ped, Config.Shops[shop].TestDriveReturnLocation.x, Config.Shops[shop].TestDriveReturnLocation.y, Config.Shops[shop].TestDriveReturnLocation.z, false, false, false, false)
                    exports.qbx_core:Notify(Lang:t('general.testdrive_complete'), 'success')
                end
            DrawText2D(Lang:t('general.testdrive_timer') .. math.ceil(time - secondsLeft / 1000), vec2(1.0, 0.93))
            end
            Wait(0)
        end
    end)
end

--- Zoning function. Happens upon entering any of the sell zone.
local function enteringVehicleSellZone()
    local job = Config.Shops[insideShop].Job
    if not QBX.PlayerData or not QBX.PlayerData.job or (QBX.PlayerData.job.name ~= job and job ~= 'none') then
        return
    end

    lib.showTextUI(Lang:t('menus.keypress_vehicleViewMenu'))
end

--- Zoning function. Happens once the player is inside of the zone
local function insideVehicleSellZone()
    local job = Config.Shops[insideShop].Job
    if not IsControlJustPressed(0, 38) or not QBX.PlayerData or not QBX.PlayerData.job or (QBX.PlayerData.job.name ~= job and job ~= 'none') then
        return
    end

    openVehicleSellMenu()
end

---@param shopName string
---@param entity number vehicle
local function createVehicleTarget(shopName, entity)
    local shop = Config.Shops[shopName]
    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'vehicleshop:showVehicleOptions',
            icon = "fas fa-car",
            label = Lang:t('general.vehinteraction'),
            distance = shop.Zone.targetDistance,
            onSelect = function()
                openVehicleSellMenu()
            end
        }
    })
end

---@param shopName string
---@param coords vector4
local function createVehicleZone(shopName, coords)
    local shop = Config.Shops[shopName]
    lib.zones.box({
        coords = coords.xyz,
        size = shop.Zone.size,
        rotation = coords.w,
        debug = shop.Zone.debug,
        onEnter = enteringVehicleSellZone,
        inside = insideVehicleSellZone,
        onExit = function()
            lib.hideTextUI()
        end
    })
end

--- Entering a vehicleshop zone
---@param self table
local function enterShop(self)
    insideShop = self.name
end

--- Exiting a vehicleshop zone
local function exitShop()
    insideShop = nil
end

--- Creates a shop
---@param shopShape vector3[]
---@param name string
local function createShop(shopShape, name)
    lib.zones.poly({
        name = name,
        points = shopShape,
        thickness = 5,
        debug = Config.Shops[name].Zone.debug,
        onEnter = enterShop,
        onExit = exitShop
    })
end

--- Entering Financing Zone
local function enteringFinancingZone()
    lib.showTextUI(Lang:t('menus.keypress_showFinanceMenu'))
end

--- Runs once a player inside the Financing Zone. It does a key press check to open the Financing menu
local function insideFinancingZone()
    if IsControlJustPressed(0, 38) then
        lib.showContext('fin_header_menu')
    end
end

---@param model string
---@param coords vector4
---@return number vehicleEntity
local function createShowroomVehicle(model, coords)
    lib.requestModel(model)
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
local function init()
    CreateThread(function()
        for name, shop in pairs(Config.Shops) do
            createShop(shop.Zone.Shape, name)
        end
    end)

    CreateThread(function()
        lib.zones.box({
            coords = Config.FinanceZone,
            size = vec3(2, 2, 4),
            rotation = 0,
            debug = false,
            onEnter = enteringFinancingZone,
            inside = insideFinancingZone,
            onExit = function()
                lib.hideTextUI()
            end
        })
    end)

    CreateThread(function()
        for shopName in pairs(Config.Shops) do
            local showroomVehicles = Config.Shops[shopName].ShowroomVehicles
            for i = 1, #showroomVehicles do
                local showroomVehicle = showroomVehicles[i]
                local veh = createShowroomVehicle(showroomVehicle.defaultVehicle, showroomVehicle.coords)
                if Config.UseTarget then
                    createVehicleTarget(shopName, veh)
                else
                    createVehicleZone(shopName, showroomVehicle.coords)
                end
            end
        end
    end)
end

--- Executes once player fully loads in
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    local citizenid = QBX.PlayerData.citizenid
    TriggerServerEvent('qb-vehicleshop:server:addPlayer', citizenid)
    TriggerServerEvent('qb-vehicleshop:server:checkFinance')
    init()
end)

--- Starts the test drive. If vehicle parameter is not provided then the test drive will start with the closest vehicle to the player.
--- @param args table
RegisterNetEvent('qb-vehicleshop:client:TestDrive', function(args)
    if inTestDrive then
        exports.qbx_core:Notify(Lang:t('error.testdrive_alreadyin'), 'error')
        return
    end

    if not args then return end

    inTestDrive = true
    local tempShop = insideShop
    local netId = lib.callback.await('qb-vehicleshop:server:spawnVehicle', false, args.vehicle, Config.Shops[tempShop].TestDriveSpawn, 'TEST ' .. RandomNumber(3))
    testDriveVeh = netId
    exports.qbx_core:Notify(Lang:t('general.testdrive_timenoti'), Config.Shops[tempShop].TestDriveTimeLimit, 'inform')
    startTestDriveTimer(Config.Shops[tempShop].TestDriveTimeLimit * 60, tempShop)
end)

--- Swaps the chosen vehicle with another one
---@param data {toVehicle: string, ClosestVehicle: integer, ClosestShop: string}
RegisterNetEvent('qb-vehicleshop:client:swapVehicle', function(data)
    local shopName = data.ClosestShop
    local dataClosestVehicle = Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle]
    if dataClosestVehicle.chosenVehicle == data.toVehicle then return end

    local closestVehicle = lib.getClosestVehicle(dataClosestVehicle.coords.xyz, 5, false)
    if not closestVehicle then return end

    DeleteEntity(closestVehicle)
    while DoesEntityExist(closestVehicle) do
        Wait(50)
    end

    local veh = createShowroomVehicle(data.toVehicle, dataClosestVehicle.coords)

    Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].chosenVehicle = data.toVehicle
    
    if Config.UseTarget then createVehicleTarget(shopName, veh) end
end)

--- Buys the selected vehicle
---@param vehicle number
---@param plate string
RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    local tempShop = insideShop -- temp hacky way of setting the shop because it changes after the callback has returned since you are outside the zone
    local netId = lib.callback.await('qb-vehicleshop:server:spawnVehicle', false, vehicle, Config.Shops[tempShop].VehicleSpawn, plate)
    local veh = NetToVeh(netId)
    local props = lib.getVehicleProperties(veh)
    props.plate = plate
    TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", props)
end)

--- Thread to create blips
CreateThread(function()
    for _, v in pairs(Config.Shops) do
        if v.showBlip then
            local dealer = AddBlipForCoord(v.Location.x, v.Location.y, v.Location.z)
            SetBlipSprite(dealer, v.blipSprite)
            SetBlipDisplay(dealer, 4)
            SetBlipScale(dealer, 0.70)
            SetBlipAsShortRange(dealer, true)
            SetBlipColour(dealer, v.blipColor)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.ShopLabel)
            EndTextCommandSetBlipName(dealer)
        end
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        if LocalPlayer.state['isLoggedIn'] then init() end
    end
end)