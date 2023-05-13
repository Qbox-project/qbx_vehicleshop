local QBCore = exports['qbx-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

lib.registerContext({
    id = 'fin_header_menu',
    title = Lang:t('menus.financed_header'),
    options = {
        {
            title = Lang:t('menus.finance_txt'),
            event = 'qb-vehicleshop:client:getVehicles'
        }
    }
})

local Initialized = false
local testDriveVeh = 0
local inTestDrive = false
local ClosestVehicle = 1
local zones = {}
local insideShop = nil
local tempShop = nil

--- Executes once player fully loads in
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    local citizenid = PlayerData.citizenid
    local gameTime = GetGameTimer()
    TriggerServerEvent('qb-vehicleshop:server:addPlayer', citizenid, gameTime)
    TriggerServerEvent('qb-vehicleshop:server:checkFinance')
    if not Initialized then Init() end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    local citizenid = PlayerData.citizenid
    TriggerServerEvent('qb-vehicleshop:server:removePlayer', citizenid)
    PlayerData = {}
end)

--- Draws Text onto the screen during test drive
---@param text string
---@param font number
---@param x number
---@param y number
---@param scale number 0.0-10.0
---@param r number red 0-255
---@param g number green 0-255
---@param b number blue 0-255
---@param a number alpha channel
local function drawTxt(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

--- Return formatted version of a value
---@param amount number
---@return string
local function comma_value(amount)
    local formatted = amount
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

--- Fetches the name of a vehicle from QB Shared
---@return string
local function getVehName()
    return QBCore.Shared.Vehicles[Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle].name
end

--- Fetches the price of a vehicle from QB Shared then it formats it into a text
---@return string
local function getVehPrice()
    return comma_value(QBCore.Shared.Vehicles[Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle].price)
end

--- Fetches the brand of a vehicle from QB Shared
---@return string
local function getVehBrand()
    return QBCore.Shared.Vehicles[Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle].brand
end

--- Sets the closest vehicle as global variable based on which vehicleshop you are in
local function setClosestShowroomVehicle()
    local pos = GetEntityCoords(cache.ped, true)
    local current = nil
    local dist = nil
    local closestShop = insideShop
    for id in pairs(Config.Shops[closestShop].ShowroomVehicles) do
        local dist2 = #(pos -vector3(Config.Shops[closestShop].ShowroomVehicles[id].coords.x,Config.Shops[closestShop].ShowroomVehicles[id].coords.y,Config.Shops[closestShop].ShowroomVehicles[id].coords.z))
        if current then
            if dist2 < dist then
                current = id
                dist = dist2
            end
        else
            dist = dist2
            current = id
        end
    end
    if current ~= ClosestVehicle then
        ClosestVehicle = current
    end
end

--- Opens the vehicle shop menu
local function openVehicleSellMenu()
    setClosestShowroomVehicle() --safety check
    if Config.Shops[insideShop].Type == 'free-use' then
        lib.registerContext({
            id = 'veh_menu',
            title = getVehBrand():upper() .. ' ' .. getVehName():upper() .. ' - $' .. getVehPrice(),
            options = {
                {
                    title = Lang:t('menus.test_header'),
                    description = Lang:t('menus.freeuse_test_txt'),
                    event = 'qb-vehicleshop:client:TestDrive'
                },
                {
                    title = Lang:t('menus.freeuse_buy_header'),
                    description = Lang:t('menus.freeuse_buy_txt'),
                    serverEvent = 'qb-vehicleshop:server:buyShowroomVehicle',
                    args = {
                        buyVehicle = Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle
                    }
                },
                {
                    title = Lang:t('menus.finance_header'),
                    description = Lang:t('menus.freeuse_finance_txt'),
                    event = 'qb-vehicleshop:client:openFinance',
                    args = {
                        price = getVehPrice(),
                        buyVehicle = Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle
                    }
                },
                {
                    title = Lang:t('menus.swap_header'),
                    description = Lang:t('menus.swap_txt'),
                    event = 'qb-vehicleshop:client:vehCategories',
                    arrow = true
                },
            }
        })
    else
        lib.registerContext({
            id = 'veh_menu',
            title = getVehBrand():upper() .. ' ' .. getVehName():upper() .. ' - $' .. getVehPrice(),
            options = {
                {
                    title = Lang:t('menus.test_header'),
                    description = Lang:t('menus.managed_test_txt'),
                    event = 'qb-vehicleshop:client:openIdMenu',
                    args = {
                        vehicle = Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle,
                        type = 'testDrive'
                    }
                },
                {
                    title = Lang:t('menus.managed_sell_header'),
                    description = Lang:t('menus.managed_sell_txt'),
                    event = 'qb-vehicleshop:client:openIdMenu',
                    args = {
                        vehicle = Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle,
                        type = 'sellVehicle'
                    }
                },
                {
                    title = Lang:t('menus.finance_header'),
                    description = Lang:t('menus.managed_finance_txt'),
                    event = 'qb-vehicleshop:client:openCustomFinance',
                    args = {
                        price = getVehPrice(),
                        vehicle = Config.Shops[insideShop].ShowroomVehicles[ClosestVehicle].chosenVehicle
                    }
                },
                {
                    title = Lang:t('menus.swap_header'),
                    description = Lang:t('menus.swap_txt'),
                    event = 'qb-vehicleshop:client:vehCategories',
                    arrow = true
                },
            }
        })
    end
    lib.showContext('veh_menu')
end

--- Starts the test drive timer based on time and shop
---@param time number
---@param shop string
local function startTestDriveTimer(time, shop)
    local gameTimer = GetGameTimer()
    CreateThread(function()
        while inTestDrive do
            if GetGameTimer() < gameTimer + tonumber(1000 * time) then
                local secondsLeft = GetGameTimer() - gameTimer
                if secondsLeft >= tonumber(1000 * time) - 20 then
                    TriggerServerEvent('qb-vehicleshop:server:deleteVehicle', testDriveVeh)
                    testDriveVeh = 0
                    inTestDrive = false
                    SetEntityCoords(cache.ped, Config.Shops[shop].TestDriveReturnLocation)
                    lib.notify({
                        title = Lang:t('general.testdrive_complete'),
                        type = 'success'
                    })
                end
                drawTxt(Lang:t('general.testdrive_timer') .. math.ceil(time - secondsLeft / 1000), 4, 0.5, 0.93, 0.50, 255, 255, 255, 180)
            end
            Wait(0)
        end
    end)
end

--- Zoning function. Happens upon entering any of the sell zone.
local function enteringVehicleSellZone()
    local job = Config.Shops[insideShop].Job
    if not PlayerData or not PlayerData.job or (PlayerData.job.name ~= job and job ~= 'none') then
        return
    end

    lib.showTextUI(Lang:t('menus.keypress_vehicleViewMenu'))
end

--- Zoning function. Happens once the player is inside of the zone
local function insideVehicleSellZone()
    local job = Config.Shops[insideShop].Job
    if not IsControlJustPressed(0, 38) or not PlayerData or not PlayerData.job or (PlayerData.job.name ~= job and job ~= 'none') then
        return
    end

    openVehicleSellMenu()
end

--- Creates vehcile zones based on a enviromental variable, wether you use target or zoneing. Entity parameter only used if enviromental variable set to targeting
---@param shopName string
---@param entity number
local function createVehicleZones(shopName, entity)
    if not Config.UsingTarget then
        for i = 1, #Config.Shops[shopName].ShowroomVehicles do
            local vehData = Config.Shops[shopName].ShowroomVehicles[i]
            zones[#zones + 1] = lib.zones.box({
                coords = vec3(vehData.coords.x, vehData.coords.y, vehData.coords.z),
                size = Config.Shops[shopName].Zone.size,
                rotation = vehData.coords.w,
                debug = Config.Shops[shopName].Zone.debug,
                onEnter = enteringVehicleSellZone,
                inside = insideVehicleSellZone,
                onExit = function()
                    lib.hideTextUI()
                end
            })
        end
    else
        exports.ox_target:addLocalEntity(entity, {
            {
                name = 'vehicleshop:showVehicleOptions',
                icon = "fas fa-car",
                label = Lang:t('general.vehinteraction'),
                distance = Config.Shops[shopName].Zone.targetDistance,
                onSelect = function()
                    openVehicleSellMenu()
                end
            }
        })
    end
end

--- Entering a vehicleshop zone
---@param self object
local function enterShop(self)
    insideShop = self.name
    setClosestShowroomVehicle()
end

--- Exiting a vehicleshop zone
local function exitShop()
    insideShop = nil
    ClosestVehicle = 1
end

--- Creates a shop
---@param shopShape vector3[]
---@param name string
function createShop(shopShape, name)
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

--- Initial function to set things up. Creating vehicleshops defined in the config and spawns the sellable vehicles
function Init()
    Initialized = true

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
        for k in pairs(Config.Shops) do
            for i = 1, #Config.Shops[k].ShowroomVehicles do
                local model = GetHashKey(Config.Shops[k].ShowroomVehicles[i].defaultVehicle)
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(0)
                end
                local veh = CreateVehicle(model, Config.Shops[k].ShowroomVehicles[i].coords.x,
                    Config.Shops[k].ShowroomVehicles[i].coords.y, Config.Shops[k].ShowroomVehicles[i].coords.z,
                    false, false)
                SetModelAsNoLongerNeeded(model)
                SetVehicleOnGroundProperly(veh)
                SetEntityInvincible(veh, true)
                SetVehicleDirtLevel(veh, 0.0)
                SetVehicleDoorsLocked(veh, 3)
                SetEntityHeading(veh, Config.Shops[k].ShowroomVehicles[i].coords.w)
                FreezeEntityPosition(veh, true)
                SetVehicleNumberPlateText(veh, 'BUY ME')
                if Config.UsingTarget then createVehicleZones(k, veh) end
            end
            if not Config.UsingTarget then createVehicleZones(k) end
        end
    end)
end

--- Opens the vehicleshop menu
RegisterNetEvent('qb-vehicleshop:client:homeMenu', function()
    openVehicleSellMenu()
end)

--- Starts the test drive. If vehicle parameter is not provided then the test drive will start with the closest vehicle to the player.
--- @param vehicle number | nil
RegisterNetEvent('qb-vehicleshop:client:TestDrive', function(vehicle)
    if not inTestDrive then
        local testDriveVehicle
        inTestDrive = true
        tempShop = insideShop

        if vehicle then
            testDriveVehicle = vehicle
        else
            testDriveVehicle = Config.Shops[tempShop].ShowroomVehicles[ClosestVehicle].chosenVehicle
        end

        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            exports.LegacyFuel:SetFuel(veh, 100)
            SetVehicleNumberPlateText(veh, 'TESTDRIVE')
            SetEntityHeading(veh, Config.Shops[tempShop].TestDriveSpawn.w)
            TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
            testDriveVeh = netId
            lib.notify({
                title = Lang:t('general.testdrive_timenoti',
                    { testdrivetime = Config.Shops[tempShop].TestDriveTimeLimit }),
                type = 'inform'
            })
        end, testDriveVehicle, Config.Shops[tempShop].TestDriveSpawn, true)
        startTestDriveTimer(Config.Shops[tempShop].TestDriveTimeLimit * 60, tempShop)
    else
        lib.notify({
            title = Lang:t('error.testdrive_alreadyin'),
            type = 'error'
        })
    end
end)

--- Destroys the vehicle
RegisterNetEvent('qb-vehicleshop:client:TestDriveReturn', function()
    local ped = cache.ped
    local veh = GetVehiclePedIsIn(ped)
    local entity = NetworkGetEntityFromNetworkId(testDriveVeh)
    if veh == entity then
        testDriveVeh = 0
        inTestDrive = false
        DeleteEntity(veh)
        lib.hideContext()
    else
        lib.notify({
            title = Lang:t('error.testdrive_return'),
            type = 'error'
        })
    end
end)

--- Opens a menu with list of vehicle categories
RegisterNetEvent('qb-vehicleshop:client:vehCategories', function()
    local categoryMenu = {
        {
            title = Lang:t('menus.goback_header'),
            icon = "fa-solid fa-angle-left",
            event = 'qb-vehicleshop:client:homeMenu'
        }
    }
    for k, v in pairs(Config.Shops[insideShop].Categories) do
        categoryMenu[#categoryMenu + 1] = {
            title = v,
            event = 'qb-vehicleshop:client:openVehCats',
            args = {
                catName = k
            }
        }
    end

    lib.registerContext({
        id = 'vehicleCategories',
        title = Lang:t('menus.categories_header'),
        options = categoryMenu
    })

    lib.showContext('vehicleCategories')
end)

--- Opens a menu with list of vehicles based on given category
---@param data string[]
RegisterNetEvent('qb-vehicleshop:client:openVehCats', function(data)
    local vehMenu = {
        {
            title = Lang:t('menus.goback_header'),
            event = 'qb-vehicleshop:client:vehCategories',
            icon = "fa-solid fa-angle-left",
        }
    }

    for k, v in pairs(QBCore.Shared.Vehicles) do
        if QBCore.Shared.Vehicles[k].category == data.catName then
            if type(QBCore.Shared.Vehicles[k].shop) == 'table' then
                for _, shop in pairs(QBCore.Shared.Vehicles[k].shop) do
                    if shop == insideShop then
                        vehMenu[#vehMenu + 1] = {
                            title = v.brand..' '..v.name,
                            description = Lang:t('menus.veh_price') .. v.price,
                            serverEvent = 'qb-vehicleshop:server:swapVehicle',
                            args = {
                                toVehicle = v.model,
                                ClosestVehicle = ClosestVehicle,
                                ClosestShop = insideShop
                            }
                        }
                    end
                end
            elseif QBCore.Shared.Vehicles[k].shop == insideShop then
                vehMenu[#vehMenu + 1] = {
                    title = v.brand..' '..v.name,
                    description = Lang:t('menus.veh_price') .. v.price,
                    serverEvent = 'qb-vehicleshop:server:swapVehicle',
                    args = {
                        toVehicle = v.model,
                        ClosestVehicle = ClosestVehicle,
                        ClosestShop = insideShop
                    }
                }
            end
        end
    end

    lib.registerContext({
        id = 'open_veh_cats',
        title = Lang:t('menus.categories_header'),
        options = vehMenu
    })

    lib.showContext('open_veh_cats')
end)

--- ?
---@params data table[]
RegisterNetEvent('qb-vehicleshop:client:openFinance', function(data)
    local dialog = lib.inputDialog(getVehBrand():upper() .. ' ' .. data.buyVehicle:upper() .. ' - $' .. data.price, {
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

    TriggerServerEvent('qb-vehicleshop:server:financeVehicle', downPayment, paymentAmount,
        data.buyVehicle)
end)

--- ?
---@params data table[]
RegisterNetEvent('qb-vehicleshop:client:openCustomFinance', function(data)
    TriggerEvent('animations:client:EmoteCommandStart', { "tablet2" })

    local dialog = lib.inputDialog(getVehBrand():upper() .. ' ' .. data.vehicle:upper() .. ' - $' .. data.price, {
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

    TriggerEvent('animations:client:EmoteCommandStart', { "c" })
    TriggerServerEvent('qb-vehicleshop:server:sellfinanceVehicle', downPayment, paymentAmount,
        data.vehicle, playerid)
end)

--- Swaps the chosen vehicle with another one
---@param data table<ClosestVehicle, toVehicle>
RegisterNetEvent('qb-vehicleshop:client:swapVehicle', function(data)
    local shopName = data.ClosestShop
    if Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].chosenVehicle ~= data.toVehicle then
        local closestVehicle, closestDistance = QBCore.Functions.GetClosestVehicle(vector3(Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.x,
            Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.y,
            Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.z))
        if closestVehicle == 0 then return end
        if closestDistance < 5 then DeleteEntity(closestVehicle) end
        while DoesEntityExist(closestVehicle) do
            Wait(50)
        end
        Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].chosenVehicle = data.toVehicle
        local model = GetHashKey(data.toVehicle)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(50)
        end
        local veh = CreateVehicle(model, Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.x,
            Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.y,
            Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.z, false, false)
        while not DoesEntityExist(veh) do
            Wait(50)
        end
        SetModelAsNoLongerNeeded(model)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh, true)
        SetEntityHeading(veh, Config.Shops[shopName].ShowroomVehicles[data.ClosestVehicle].coords.w)
        SetVehicleDoorsLocked(veh, 3)
        FreezeEntityPosition(veh, true)
        SetVehicleNumberPlateText(veh, 'BUY ME')
        if Config.UsingTarget then createVehicleZones(shopName, veh) end
    end
end)

--- Buys the selected vehicle
---@param vehicle number
---@param plate string
RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    tempShop = insideShop -- temp hacky way of setting the shop because it changes after the callback has returned since you are outside the zone
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        exports.LegacyFuel:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.Shops[tempShop].VehicleSpawn.w)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
    end, vehicle, Config.Shops[tempShop].VehicleSpawn, true)
end)

--- Gets the owned vehicles based on financing then opens a menu
RegisterNetEvent('qb-vehicleshop:client:getVehicles', function()
    QBCore.Functions.TriggerCallback('qb-vehicleshop:server:getVehicles', function(vehicles)
        local ownedVehicles = {}
        for _, v in pairs(vehicles) do
            if v.balance ~= 0 then
                local name = QBCore.Shared.Vehicles[v.vehicle].name
                local plate = v.plate:upper()
                ownedVehicles[#ownedVehicles + 1] = {
                    title = name,
                    description = Lang:t('menus.veh_platetxt') .. plate,
                    icon = "fa-solid fa-car-side",
                    event = 'qb-vehicleshop:client:getVehicleFinance',
                    args = {
                        vehiclePlate = plate,
                        balance = v.balance,
                        paymentsLeft = v.paymentsleft,
                        paymentAmount = v.paymentamount
                    }
                }
            end
        end

        lib.registerContext({
            id = 'owned_vehicles',
            title = Lang:t('menus.owned_vehicles_header'),
            options = ownedVehicles
        })

        if #ownedVehicles > 0 then
            lib.showContext('owned_vehicles')
        else
            lib.notify({
                title = Lang:t('error.nofinanced'),
                type = 'error',
                duration = 7500
            })
        end
    end)
end)

RegisterNetEvent('qb-vehicleshop:client:getVehicleFinance', function(data)
    local vehFinance = {
        {
            title = Lang:t('menus.goback_header'),
            event = 'qb-vehicleshop:client:getVehicles',
            icon = "fa-solid fa-angle-left",
        },
        {
            title = Lang:t('menus.veh_finance_balance'),
            description = Lang:t('menus.veh_finance_currency') .. comma_value(data.balance)
        },
        {
            title = Lang:t('menus.veh_finance_total'),
            description = data.paymentsLeft
        },
        {
            title = Lang:t('menus.veh_finance_reccuring'),
            description = Lang:t('menus.veh_finance_currency') .. comma_value(data.paymentAmount)
        },
        {
            title = Lang:t('menus.veh_finance_pay'),
            event = 'qb-vehicleshop:client:financePayment',
            args = {
                vehData = data,
                paymentsLeft = data.paymentsleft,
                paymentAmount = data.paymentamount
            }
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
        options = vehFinance
    })

    lib.showContext('vehFinance')
end)

RegisterNetEvent('qb-vehicleshop:client:financePayment', function(data)
    local dialog = lib.inputDialog(Lang:t('menus.veh_finance'), {
        {
            type = 'number',
            label = Lang:t('menus.veh_finance_payment'),
            placeholder = 1000
        }
    })

    if not dialog then return end

    local paymentAmount = tonumber(dialog[1])
    TriggerServerEvent('qb-vehicleshop:server:financePayment', paymentAmount, data.vehData)
end)

RegisterNetEvent('qb-vehicleshop:client:openIdMenu', function(data)
    local dialog = lib.inputDialog(QBCore.Shared.Vehicles[data.vehicle].name, {
        {
            type = 'number',
            label = Lang:t('menus.submit_ID'),
            placeholder = 1
        }
    })

    if not dialog then return end
    if not dialog[1] then return end

    local playerId = tonumber(dialog[1])
    if data.type == 'testDrive' then
        TriggerServerEvent('qb-vehicleshop:server:customTestDrive', data.vehicle, playerId)
    elseif data.type == 'sellVehicle' then
        TriggerServerEvent('qb-vehicleshop:server:sellShowroomVehicle', data.vehicle, playerId)
    end
end)

--- Thread to create blips
CreateThread(function()
    for k, v in pairs(Config.Shops) do
        if v.showBlip then
            local Dealer = AddBlipForCoord(Config.Shops[k].Location)
            SetBlipSprite(Dealer, Config.Shops[k].blipSprite)
            SetBlipDisplay(Dealer, 4)
            SetBlipScale(Dealer, 0.70)
            SetBlipAsShortRange(Dealer, true)
            SetBlipColour(Dealer, Config.Shops[k].blipColor)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.Shops[k].ShopLabel)
            EndTextCommandSetBlipName(Dealer)
        end
    end
end)
