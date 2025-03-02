local config = require 'config.client'
local sharedConfig = require 'config.shared'
local vehiclesMenu = require 'client.vehicles'
local VEHICLES = exports.qbx_core:GetVehiclesByName()
local VEHICLES_HASH = exports.qbx_core:GetVehiclesByHash()
local insideShop
local showroomPoints = {}

---@param data VehicleFinanceClient
local function financePayment(data)
    local dialog = lib.inputDialog(locale('menus.veh_finance'), {
        {
            type = 'number',
            label = locale('menus.veh_finance_payment'),
        }
    })

    if not dialog then return end

    local amount = tonumber(dialog[1])
    TriggerServerEvent('qbx_vehicleshop:server:financePayment', amount, data.vehId)
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
    local label = ('%s %s'):format(data.brand, data.name)
    local options = {
        {
            title = 'Finance Information',
            icon = 'circle-info',
            description = ('Name: %s\nPlate: %s\nRemaining Balance: $%s\nRecurring Payment Amount: $%s\nPayments Left: %s'):format(label, data.vehiclePlate, lib.math.groupdigits(data.balance), lib.math.groupdigits(data.paymentAmount), data.paymentsLeft),
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
                    TriggerServerEvent('qbx_vehicleshop:server:financePaymentFull', data.vehId)
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
        options = options
    })

    lib.showContext('vehicleFinance')
end

local function openPaymentMethodMenu(vehicleModel)
    local vehiclePrice = VEHICLES[vehicleModel].price

    lib.registerContext({
        id = 'paymentMethodMenu',
        title = 'Selecciona un Método de Pago',
        options = {
            {
                title = '💵 Pagar en Efectivo',
                description = ('Precio: $%s'):format(lib.math.groupdigits(vehiclePrice)),
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    TriggerServerEvent('qbx_vehicleshop:server:buyShowroomVehicle', vehicleModel, 'cash')
                end
            },
            {
                title = '🏦 Pagar con Cuenta Bancaria',
                description = ('Precio: $%s'):format(lib.math.groupdigits(vehiclePrice)),
                icon = 'fa-solid fa-building-columns',
                onSelect = function()
                    TriggerServerEvent('qbx_vehicleshop:server:buyShowroomVehicle', vehicleModel, 'bank')
                end
            }
        }
    })
    lib.showContext('paymentMethodMenu')
end
--- Gets the owned vehicles based on financing then opens a menu
local function showFinancedVehiclesMenu()
    local vehicles = lib.callback.await('qbx_vehicleshop:server:GetFinancedVehicles')
    local options = {}

    if not vehicles or #vehicles == 0 then
        return exports.qbx_core:Notify(locale('error.nofinanced'), 'error')
    end

    for _, v in pairs(vehicles) do
        local plate = v.props.plate
        local vehicle = VEHICLES[v.modelName]

        plate = plate and plate:upper()

        options[#options + 1] = {
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

    if #options == 0 then
        return exports.qbx_core:Notify(locale('error.nofinanced'), 'error')
    end

    lib.registerContext({
        id = 'ownedVehicles',
        title = locale('menus.owned_vehicles_header'),
        options = options
    })

    lib.showContext('ownedVehicles')
end

---@param closestVehicle integer
---@return string
local function getVehName(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return VEHICLES[vehicle].name
end

---@param closestVehicle integer
---@return string
local function getVehPrice(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return lib.math.groupdigits(VEHICLES[vehicle].price)
end

---@param closestVehicle integer
---@return string
local function getVehBrand(closestVehicle)
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[closestVehicle].vehicle

    return VEHICLES[vehicle].brand
end

---@param targetShowroomVehicle integer Showroom position index
---@param buyVehicle string model
local function openFinance(targetShowroomVehicle, buyVehicle)
    local shopName = insideShop
    if not shopName then
        return exports.qbx_core:Notify('No estás en un concesionario.', 'error')
    end

    -- Si targetShowroomVehicle es un número, convertirlo en una tabla con "id"
    if type(targetShowroomVehicle) == "number" then
        targetShowroomVehicle = { id = targetShowroomVehicle }
    end

    -- Si no tiene "id", buscar el más cercano
    if not targetShowroomVehicle or not targetShowroomVehicle.id then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestShowroom = nil
        local minDistance = math.huge

        for i, vehicleData in pairs(sharedConfig.shops[shopName].showroomVehicles) do
            local vehCoords = vehicleData.coords.xyz
            local distance = #(playerCoords - vehCoords)

            if distance < minDistance then
                minDistance = distance
                closestShowroom = { id = i } -- 🔵 Ahora guardamos correctamente la estructura
            end
        end

        targetShowroomVehicle = closestShowroom
    end

    -- Verificar si finalmente tenemos un showroom válido
    if not targetShowroomVehicle or not targetShowroomVehicle.id then
        return exports.qbx_core:Notify('No se encontró un vehículo en el showroom.', 'error')
    end

    -- Obtener precio correctamente sin error
    local price = getVehPrice(targetShowroomVehicle.id)
    if not price then
        return exports.qbx_core:Notify('Error al obtener el precio del vehículo.', 'error')
    end

    local title = ('%s %s - $%s'):format(VEHICLES[buyVehicle].brand:upper(), VEHICLES[buyVehicle].name:upper(), price)

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

    for i = 1, vehiclesMenu.count do
        local vehicle = vehiclesMenu.vehicles[i]
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
---@param targetVehicle integer
--- Abre un buscador de vehículos por nombre
local function openVehicleSearchMenu()
    local dialog = lib.inputDialog('Buscar Vehículo', {
        {
            type = 'input',
            label = 'Nombre del Vehículo',
            placeholder = 'Ejemplo: Sultan, Dominator...',
        }
    })

    if not dialog or not dialog[1] then return end -- Si el jugador cancela, salimos

    local searchQuery = dialog[1]:lower() -- Convertimos el texto a minúsculas para búsqueda flexible
    local options = {}

    -- Verificar que estamos dentro de una tienda
    local shopName = insideShop
    if not shopName then
        return exports.qbx_core:Notify('No estás en un concesionario.', 'error')
    end

    -- Obtener el vehículo más cercano dentro del showroom
    local targetShowroomVehicle
    local playerCoords = GetEntityCoords(PlayerPedId()) -- Obtener posición del jugador

    for i, vehicleData in pairs(sharedConfig.shops[shopName].showroomVehicles) do
        local vehCoords = vehicleData.coords.xyz -- Posición del vehículo en showroom
        local distance = #(playerCoords - vehCoords)

        if not targetShowroomVehicle or distance < targetShowroomVehicle.distance then
            targetShowroomVehicle = { id = i, distance = distance }
        end
    end

    if not targetShowroomVehicle then
        return exports.qbx_core:Notify('No se encontró un vehículo cercano para cambiar.', 'error')
    end

    -- Buscar vehículos que coincidan con la búsqueda
    for model, vehicle in pairs(VEHICLES) do
        if vehicle.name:lower():find(searchQuery) or vehicle.brand:lower():find(searchQuery) then
            options[#options + 1] = {
                title = ('%s %s'):format(vehicle.brand, vehicle.name),
                description = ('Precio: $%s'):format(lib.math.groupdigits(vehicle.price)),
                icon = 'fa-solid fa-car',
                arrow = true,
                onSelect = function()
                    -- Enviar evento para cambiar el vehículo correcto en el showroom
                    TriggerServerEvent('qbx_vehicleshop:server:swapVehicle', {
                        toVehicle = model,
                        targetVehicle = targetShowroomVehicle.id,
                        closestShop = shopName
                    })

                    -- Mostrar el menú de opciones de compra o financiamiento
                    lib.registerContext({
                        id = 'vehicleOptions_' .. model,
                        title = ('%s %s'):format(vehicle.brand, vehicle.name),
                        options = {
                            {
                                title = '💰 Comprar',
                                description = ('Precio: $%s'):format(lib.math.groupdigits(vehicle.price)),
                                icon = 'fa-solid fa-money-bill',
                                onSelect = function()
                                    openPaymentMethodMenu(model) -- ✅ Esto abrirá el menú para seleccionar el método de pago
                                end
                            },
                            {
                                title = '🏦 Financiar',
                                description = 'Pagar en cuotas mensuales',
                                icon = 'fa-solid fa-hand-holding-dollar',
                                onSelect = function()
                                    openFinance(nil, model)
                                end
                            }
                        }
                    })
                    lib.showContext('vehicleOptions_' .. model)
                end
            }
        end
    end

    if #options == 0 then
        return exports.qbx_core:Notify('No se encontraron vehículos con ese nombre.', 'error')
    end

    -- Mostrar menú con resultados de búsqueda
    lib.registerContext({
        id = 'searchResults',
        title = 'Resultados de Búsqueda',
        options = options
    })

    lib.showContext('searchResults')
end


local function openVehicleCategoryMenu(targetVehicle)
    local categoryMenu = {}
    local sortedCategories = {}
    local categories = sharedConfig.shops[insideShop].categories

    -- 📌 Primero agregamos el botón de búsqueda para que quede arriba
    categoryMenu[#categoryMenu + 1] = {
        title = '🔍 Buscar Vehículo',
        description = 'Escribe el nombre de un vehículo para buscarlo',
        icon = 'fa-solid fa-magnifying-glass',
        onSelect = function()
            openVehicleSearchMenu()
        end
    }

    -- Ordenamos las categorías antes de agregarlas
    for k, v in pairs(categories) do
        sortedCategories[#sortedCategories + 1] = {
            category = k,
            label = v
        }
    end

    table.sort(sortedCategories, function(a, b)
        return a.label:upper() < b.label:upper()
    end)

    -- Agregamos las categorías después del botón de búsqueda
    for i = 1, #sortedCategories do
        categoryMenu[#categoryMenu + 1] = {
            title = sortedCategories[i].label,
            arrow = true,
            onSelect = function()
                openVehCatsMenu(sortedCategories[i].category, targetVehicle)
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


---@param targetVehicle integer Showroom position index
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
    local playerId = tonumber(dialog[3])

    if not downPayment or not paymentAmount or not playerId then return end

    TriggerServerEvent('qbx_vehicleshop:server:sellfinanceVehicle', downPayment, paymentAmount, vehicle, playerId)
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

lib.onCache('vehicle', function(value)
    if value or not LocalPlayer.state.isInTestDrive then return end
    LocalPlayer.state:set('isInTestDrive', nil, true)
end)

---@param vehModel string
local function sellVehicle(vehModel)
    local playerId = getPlayerIdInput(vehModel)

    TriggerServerEvent('qbx_vehicleshop:server:sellShowroomVehicle', vehModel, playerId)
end

---@param vehicle string Modelo del vehículo que se va a comprar

--- Opens the vehicle shop menu
---@param targetVehicle number
local function openVehicleSellMenu(targetVehicle)
    local options = {}
    local vehicle = sharedConfig.shops[insideShop].showroomVehicles[targetVehicle].vehicle
    local swapOption = {
        title = locale('menus.swap_header'),
        description = locale('menus.swap_txt'),
        onSelect = function()
            openVehicleCategoryMenu(targetVehicle)
        end,
        arrow = true
    }

    if sharedConfig.shops[insideShop].type == 'free-use' then
        if sharedConfig.enableTestDrive then
            options[#options + 1] = {
                title = locale('menus.test_header'),
                description = locale('menus.freeuse_test_txt'),
                onSelect = function()
                    TriggerServerEvent('qbx_vehicleshop:server:testDrive', vehicle)
                end,
            }
        end

        if sharedConfig.enableFreeUseBuy then
            options[#options + 1] = {
                title = locale('menus.freeuse_buy_header'),
                description = locale('menus.freeuse_buy_txt'),
                onSelect = function()
                    openPaymentMethodMenu(vehicle)
                end,
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

---@param shopName string
---@param entity number vehicle
---@param targetVehicle number
local function createVehicleTarget(shopName, entity, targetVehicle)
    local shop = sharedConfig.shops[shopName]

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'showVehicleOptions',
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

    local boxZone = lib.zones.box({
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
    return boxZone
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
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, false, true)
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(veh)
    SetEntityInvincible(veh, true)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleDoorsLocked(veh, 10)
    FreezeEntityPosition(veh, true)
    SetVehicleNumberPlateText(veh, 'BUY ME')

    return veh
end

local function openPaymentMethodMenu(vehicleModel)
    local vehiclePrice = VEHICLES[vehicleModel].price

    lib.registerContext({
        id = 'paymentMethodMenu',
        title = 'Selecciona un Método de Pago',
        options = {
            {
                title = '💵 Pagar en Efectivo',
                description = ('Precio: $%s'):format(lib.math.groupdigits(vehiclePrice)),
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    TriggerServerEvent('qbx_vehicleshop:server:buyShowroomVehicle', vehicleModel, 'cash')
                end
            },
            {
                title = '🏦 Pagar con Cuenta Bancaria',
                description = ('Precio: $%s'):format(lib.math.groupdigits(vehiclePrice)),
                icon = 'fa-solid fa-building-columns',
                onSelect = function()
                    TriggerServerEvent('qbx_vehicleshop:server:buyShowroomVehicle', vehicleModel, 'bank')
                end
            }
        }
    })
    lib.showContext('paymentMethodMenu')
end

local function createShowroomVehiclePoint(data)
    local vehPoint = lib.points.new({
        coords = data.coords,
        heading = data.coords.w,
        distance = 300,
        shopName = data.shopName,
        vehiclePos = data.vehiclePos,
        model = data.model,
        veh = nil,
        boxZone = nil,
        onEnter = function(self)
            self.veh = createShowroomVehicle(self.model, vec4(self.coords.x, self.coords.y, self.coords.z, self.heading))

            if config.useTarget then
                createVehicleTarget(self.shopName, self.veh, self.vehiclePos)
            else
                self.boxZone = createVehicleZone(self.shopName, self.coords, self.vehiclePos)
            end
        end,
        onExit = function(self)
            if config.useTarget then
                exports.ox_target:removeLocalEntity(self.veh, 'showVehicleOptions')
            else
                self.boxZone:remove()
            end

            if DoesEntityExist(self.veh) then
                DeleteEntity(self.veh)
            end

            self.veh = nil
            self.boxZone = nil
        end
    })

    return vehPoint
end

--- Starts the test drive timer based on time and shop
---@param time integer
local function startTestDriveTimer(time)
    local gameTimer = GetGameTimer()

    CreateThread(function()
        local playerState = LocalPlayer.state
        while playerState.isInTestDrive do
            local currentGameTime = GetGameTimer()
            local secondsLeft = currentGameTime - gameTimer

            qbx.drawText2d({
                text = locale('general.testdrive_timer')..math.ceil(time - secondsLeft / 1000),
                coords = vec2(1.0, 1.38),
                scale = 0.5
            })

            Wait(0)
        end
        exports.qbx_core:Notify(locale('general.testdrive_complete'), 'success')
    end)
end

AddStateBagChangeHandler('isInTestDrive', ('player:%s'):format(cache.serverId), function(_, _, value)
    if not value then return end

    while not cache.vehicle do
        Wait(10)
    end

    exports.qbx_core:Notify(locale('general.testdrive_timenoti', value), 'inform')
    startTestDriveTimer(value * 60)
end)

--- Swaps the chosen vehicle with another one
---@param data {toVehicle: string, targetVehicle: integer, closestShop: string}
RegisterNetEvent('qbx_vehicleshop:client:swapVehicle', function(data)
    local shopName = data.closestShop
    local dataTargetVehicle = sharedConfig.shops[shopName].showroomVehicles[data.targetVehicle]
    local vehPoint = showroomPoints[shopName][data.targetVehicle]

    if not vehPoint or dataTargetVehicle.vehicle == data.toVehicle then return end

    if not IsModelInCdimage(data.toVehicle) then
        lib.print.error(('Failed to find model for "%s". Vehicle might not be streamed?'):format(data.toVehicle))
        return
    end

    dataTargetVehicle.vehicle = data.toVehicle
    vehPoint.model = data.toVehicle
    if vehPoint.currentDistance <= vehPoint.distance then
        vehPoint:onExit()
        vehPoint:onEnter()
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

lib.callback.register('qbx_vehicleshop:client:confirmFinance', function(financeData)
    local alert = lib.alertDialog({
        header = locale('general.financed_vehicle_header'),
        content = locale('general.financed_vehicle_warning', lib.math.groupdigits(financeData.balance), lib.math.groupdigits(financeData.paymentamount), financeData.timer),
        centered = true,
        cancel = true,
        labels = {
            cancel = 'No',
            confirm = 'Yes',
        }
    })
    return alert
end)

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
    if sharedConfig.finance.enable then
        if config.useTarget then
            exports.ox_target:addBoxZone({
                coords = sharedConfig.finance.zone,
                size = vec3(2, 2, 4),
                rotation = 0,
                debug = config.debugPoly,
                options = {
                    {
                        name = 'showFinanceMenu',
                        icon = 'fas fa-money-check',
                        label = locale('menus.finance_menu'),
                        onSelect = function()
                            showFinancedVehiclesMenu()
                        end
                    }
                }
            })
        else
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
    end

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

    for shopName, shop in pairs(sharedConfig.shops) do
        createShop(shop.zone.shape, shopName)
        showroomPoints[shopName] = {}

        local showroomVehicles = sharedConfig.shops[shopName].showroomVehicles
        for i = 1, #showroomVehicles do
            local showroomVehicle = showroomVehicles[i]
            showroomPoints[shopName][i] = createShowroomVehiclePoint({
                coords = showroomVehicle.coords,
                shopName = shopName,
                vehiclePos = i,
                model = showroomVehicle.vehicle
            })
        end
    end
end)