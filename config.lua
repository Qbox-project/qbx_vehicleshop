Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.Commission = 0.10 -- Percent that goes to sales person from a full car sale 10%
Config.FinanceCommission = 0.05 -- Percent that goes to sales person from a finance sale 5%
Config.FinanceZone = vec3(-29.53, -1103.67, 26.42)-- Where the finance menu is located
Config.PaymentWarning = 10 -- time in minutes that player has to make payment before repo
Config.PaymentInterval = 24 -- time in hours between payment being due
Config.MinimumDown = 10 -- minimum percentage allowed down
Config.MaximumPayments = 24 -- maximum payments allowed
Config.PreventFinanceSelling = false -- allow/prevent players from using /transfervehicle if financed

Config.Shops = {
    --[[
    ['pdm'] = {
        zone = {
            points = { -- polygon that surrounds the shop
                vec3(-56.727394104004, 26.0, -1086.2325439453)
            },
            size = 2.75 -- size of the vehicles zones
        },
        blip = { Blip or nil
            coords = vec3(-45.67, -1098.34, 26.42), -- Blip Location
            label = 'Premium Deluxe Motorsport', -- Blip name
            sprite = 326, -- Blip sprite
            color = 3 -- Blip color
        },
        job = 'name', -- Name of job or nil
        categories = {-- Categories available to browse
            ['sportsclassics'] = 'Sports Classics'
        },
        testDriveTimeLimit = 0.5, -- Time in minutes until the vehicle gets deleted
        returnLocation = vec3(-44.74, -1082.58, 26.68), -- Location to return vehicle, only enables if the vehicleshop has a job owned
        vehicleSpawn = vec4(-56.79, -1109.85, 26.43, 71.5), -- Spawn location when vehicle is bought
        testDriveSpawn = vec4(-56.79, -1109.85, 26.43, 71.5), -- Spawn location for test drive
        showroomVehicles = {
            [1] = {
                coords = vec4(-45.65, -1093.66, 25.44, 69.5), -- where the vehicle will spawn on display
                defaultVehicle = 'adder', -- Default display vehicle
                chosenVehicle = 'adder' -- Same as default but is dynamically changed when swapping vehicles
            }
        }
    },
    ]]
    ['pdm'] = {
        zone = {
            points = {
                vec3(-56.727394104004, 26.0, -1086.2325439453),
                vec3(-60.612808227539, 26.0, -1096.7795410156),
                vec3(-58.26834487915, 26.0, -1100.572265625),
                vec3(-35.927803039551, 26.0, -1109.0034179688),
                vec3(-34.427627563477, 26.0, -1108.5111083984),
                vec3(-32.02657699585, 26.0, -1101.5877685547),
                vec3(-33.342102050781, 26.0, -1101.0377197266),
                vec3(-31.292987823486, 26.0, -1095.3717041016)
            },
            size = 2.75
        },
        blip = {
            coords = vec3(-45.67, -1098.34, 26.42),
            label = 'Premium Deluxe Motorsport',
            sprite = 326,
            color = 3
        },
        categories = {
            ['sportsclassics'] = 'Sports Classics',
            ['sedans'] = 'Sedans',
            ['coupes'] = 'Coupes',
            ['suvs'] = 'SUVs',
            ['offroad'] = 'Offroad',
            ['muscle'] = 'Muscle',
            ['compacts'] = 'Compacts',
            ['motorcycles'] = 'Motorcycles',
            ['vans'] = 'Vans',
            ['cycles'] = 'Bicycles',
            ['super'] = 'Super',
            ['sports'] = 'Sports'
        },
        testDriveTimeLimit = 0.5,
        returnLocation = vec3(-44.74, -1082.58, 26.68),
        vehicleSpawn = vec4(-56.79, -1109.85, 26.43, 71.5),
        testDriveSpawn = vec4(-56.79, -1109.85, 26.43, 71.5),
        showroomVehicles = {
            [1] = {
                coords = vec4(-45.65, -1093.66, 25.44, 69.5),
                defaultVehicle = 'adder',
                chosenVehicle = 'adder'
            },
            [2] = {
                coords = vec4(-48.27, -1101.86, 25.44, 294.5),
                defaultVehicle = 'schafter2',
                chosenVehicle = 'schafter2'
            },
            [3] = {
                coords = vec4(-39.6, -1096.01, 25.44, 66.5),
                defaultVehicle = 'comet2',
                chosenVehicle = 'comet2'
            },
            [4] = {
                coords = vec4(-51.21, -1096.77, 25.44, 254.5),
                defaultVehicle = 'vigero',
                chosenVehicle = 'vigero'
            },
            [5] = {
                coords = vec4(-40.18, -1104.13, 25.44, 338.5),
                defaultVehicle = 't20',
                chosenVehicle = 't20'
            },
            [6] = {
                coords = vec4(-43.31, -1099.02, 25.44, 52.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            },
            [7] = {
                coords = vec4(-50.66, -1093.05, 25.44, 222.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            },
            [8] = {
                coords = vec4(-44.28, -1102.47, 25.44, 298.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            }
        }
    },
    ['boats'] = {
        zone = {
            points = {
                vec3(-729.39, 3.0, -1315.84),
                vec3(-766.81, 3.0, -1360.11),
                vec3(-754.21, 3.0, -1371.49),
                vec3(-716.94, 3.0, -1326.88)
            },
            size = 6.2
        },
        blip = {
            coords = vec3(-738.25, -1334.38, 1.6),
            label = 'Marina Shop',
            sprite = 410,
            color = 3
        },
        categories = {
            ['boats'] = 'Boats'
        },
        testDriveTimeLimit = 1.5,
        returnLocation = vec3(-714.34, -1343.31, 0.0),
        vehicleSpawn = vec4(-727.87, -1353.1, -0.17, 137.09),
        testDriveSpawn = vec4(-722.23, -1351.98, 0.14, 135.33),
        showroomVehicles = {
            [1] = {
                coords = vec4(-727.05, -1326.59, 0.00, 229.5),
                defaultVehicle = 'seashark',
                chosenVehicle = 'seashark'
            },
            [2] = {
                coords = vec4(-732.84, -1333.5, -0.50, 229.5),
                defaultVehicle = 'dinghy',
                chosenVehicle = 'dinghy'
            },
            [3] = {
                coords = vec4(-737.84, -1340.83, -0.50, 229.5),
                defaultVehicle = 'speeder',
                chosenVehicle = 'speeder'
            },
            [4] = {
                coords = vec4(-741.53, -1349.7, -2.00, 229.5),
                defaultVehicle = 'marquis',
                chosenVehicle = 'marquis'
            }
        }
    },
    ['air'] = {
        zone = {
            points = {
                vec3(-1607.58, 14.0, -3141.7),
                vec3(-1672.54, 14.0, -3103.87),
                vec3(-1703.49, 14.0, -3158.02),
                vec3(-1646.03, 14.0, -3190.84)
            },
            size = 7.0
        },
        blip = {
            coords = vec3(-1652.76, -3143.4, 13.99),
            label = 'Air Shop',
            sprite = 251,
            color = 3
        },
        categories = {
            ['helicopters'] = 'Helicopters',
            ['planes'] = 'Planes'
        },
        testDriveTimeLimit = 1.5,
        returnLocation = vec3(-1628.44, -3104.7, 13.94),
        vehicleSpawn = vec4(-1617.49, -3086.17, 13.94, 329.2),
        testDriveSpawn = vec4(-1625.19, -3103.47, 13.94, 330.28),
        showroomVehicles = {
            [1] = {
                coords = vec4(-1651.36, -3162.66, 12.99, 346.89),
                defaultVehicle = 'volatus',
                chosenVehicle = 'volatus'
            },
            [2] = {
                coords = vec4(-1668.53, -3152.56, 12.99, 303.22),
                defaultVehicle = 'luxor2',
                chosenVehicle = 'luxor2'
            },
            [3] = {
                coords = vec4(-1632.02, -3144.48, 12.99, 31.08),
                defaultVehicle = 'nimbus',
                chosenVehicle = 'nimbus'
            },
            [4] = {
                coords = vec4(-1663.74, -3126.32, 12.99, 275.03),
                defaultVehicle = 'frogger',
                chosenVehicle = 'frogger'
            }
        }
    }
}