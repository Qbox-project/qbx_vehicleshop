return {
    finance = {
        minimumDown = 10, -- minimum percentage allowed down
        maximumPayments = 24, -- maximum payments allowed
        enable = true, -- Enables the financing system. Turning this off does not affect already financed vehicles
        zone = vec3(-29.53, -1103.67, 26.42), -- Where the finance menu is located
    },

    enableFreeUseBuy = true, -- Allows players to buy from NPC shops
    enableTestDrive = true,

    vehicles = {

        -- For the configuration below, it would first look for the vehicle in models.
        -- If not found, it would check for the category in categories.
        -- If the category is also not found, it would default to the default settings.
        -- To disable a vehicle from being sold, define it within the blocklist.
        default = 'pdm',

        categories = {
            boats = 'boats',
            air = 'air',
            -- super = {'pdm', 'luxury'},
        },

        models = {
            -- zentorno = {'pdm', 'luxury'},

            oppressor = 'luxury',
            --- Sports
            alpha = 'luxury',
            banshee = 'luxury',
            bestiagts = 'luxury',
            buffalo = 'luxury',
            buffalo2 = 'luxury',
            carbonizzare = 'luxury',
            comet2 = 'luxury',
            comet3 = 'luxury',
            comet4 = 'luxury',
            comet5 = 'luxury',
            coquette = 'luxury',
            coquette4 = 'luxury',
            drafter = 'luxury',
            deveste = 'luxury',
            elegy = 'luxury',
            elegy2 = 'luxury',
            feltzer2 = 'luxury',
            flashgt = 'luxury',
            furoregt = 'luxury',
            gb200 = 'luxury',
            komoda = 'luxury',
            imorgon = 'luxury',
            italigto = 'luxury',
            jugular = 'luxury',
            jester = 'luxury',
            jester2 = 'luxury',
            jester3 = 'luxury',
            khamelion = 'luxury',
            kuruma = 'luxury',
            kuruma2 = 'luxury',
            locust = 'luxury',
            lynx = 'luxury',
            massacro = 'luxury',
            massacro2 = 'luxury',
            neo = 'luxury',
            neon = 'luxury',
            ninef = 'luxury',
            ninef2 = 'luxury',
            omnis = 'luxury',
            paragon = 'luxury',
            pariah = 'luxury',
            penumbra = 'luxury',
            penumbra2 = 'luxury',
            rapidgt = 'luxury',
            rapidgt2 = 'luxury',
            raptor = 'luxury',
            revolter = 'luxury',
            ruston = 'luxury',
            schafter3 = 'luxury',
            schafter4 = 'luxury',
            schlagen = 'luxury',
            schwarzer = 'luxury',
            seven70 = 'luxury',
            specter = 'luxury',
            streiter = 'luxury',
            sugoi = 'luxury',
            sultan = 'luxury',
            sultan2 = 'luxury',
            surano = 'luxury',
            tropos = 'luxury',
            verlierer2 = 'luxury',
            vstr = 'luxury',
            italirsx = 'luxury',
            zr350 = 'luxury',
            calico = 'luxury',
            futo2 = 'luxury',
            euros = 'luxury',
            jester4 = 'luxury',
            remus = 'luxury',
            comet6 = 'luxury',
            growler = 'luxury',
            vectre = 'luxury',
            cypher = 'luxury',
            sultan3 = 'luxury',
            rt3000 = 'luxury',

            --- Sports Classic
            cheetah2 = 'luxury',

            --- Super
            adder = 'luxury',
            autarch = 'luxury',
            banshee2 = 'luxury',
            bullet = 'luxury',
            cheetah = 'luxury',
            corsita = 'luxury',
            cyclone = 'luxury',
            entity2 = 'luxury',
            entityxf = 'luxury',
            emerus = 'luxury',
            fmj = 'luxury',
            furia = 'luxury',
            gp1 = 'luxury',
            infernus = 'luxury',
            italigtb = 'luxury',
            italigtb2 = 'luxury',
            krieger = 'luxury',
            le7b = 'luxury',
            lm87 = 'luxury',
            nero = 'luxury',
            nero2 = 'luxury',
            omnisegt = 'luxury',
            osiris = 'luxury',
            penetrator = 'luxury',
            pfister811 = 'luxury',
            prototipo = 'luxury',
            reaper = 'luxury',
            s80 = 'luxury',
            sc1 = 'luxury',
            sentinel4 = 'luxury',
            sheava = 'luxury',
            sm722 = 'luxury',
            sultanrs = 'luxury',
            t20 = 'luxury',
            taipan = 'luxury',
            tempesta = 'luxury',
            tenf = 'luxury',
            tenf2 = 'luxury',
            torero2 = 'luxury',
            tezeract = 'luxury',
            thrax = 'luxury',
            tigon = 'luxury',
            turismor = 'luxury',
            tyrant = 'luxury',
            tyrus = 'luxury',
            vacca = 'luxury',
            vagner = 'luxury',
            visione = 'luxury',
            voltic = 'luxury',
            voltic2 = 'luxury',
            xa21 = 'luxury',
            zentorno = 'luxury',
            zorrusso = 'luxury',

            --- Boats
            squalo = 'boats',
            marquis = 'boats',
            seashark = 'boats',
            seashark2 = 'boats',
            seashark3 = 'boats',
            jetmax = 'boats',
            tropic = 'boats',
            tropic2 = 'boats',
            dinghy = 'boats',
            dinghy2 = 'boats',
            dinghy3 = 'boats',
            dinghy4 = 'boats',
            suntrap = 'boats',
            speeder = 'boats',
            speeder2 = 'boats',
            longfin = 'boats',
            toro = 'boats',
            toro2 = 'boats',

            --- Helicopters
            buzzard2 = 'air',
            frogger = 'air',
            frogger2 = 'air',
            maverick = 'air',
            swift = 'air',
            swift2 = 'air',
            seasparrow = 'air',
            seasparrow2 = 'air',
            seasparrow3 = 'air',
            supervolito = 'air',
            supervolito2 = 'air',
            volatus = 'air',
            havok = 'air',

            --- Planes
            duster = 'air',
            luxor = 'air',
            luxor2 = 'air',
            stunt = 'air',
            mammatus = 'air',
            velum = 'air',
            velum2 = 'air',
            shamal = 'air',
            vestra = 'air',
            dodo = 'air',
            howard = 'air',
            alphaz1 = 'air',
            nimbus = 'air',
            conada = 'air',
        },

        blocklist = {
            'police',
            'police2',
            'police3',
            'police4',
        }
    },

    shops = {
        --[[shop = { -- Needs to be unique
            type = '', -- If 'free-use', no player-to-player interaction required to purchase. If 'managed', caresalesman required for purchase
            job = '', -- If shop is 'free-use', remove this option. If shop is 'managed', put required job
            zone = {
                shape = { -- Polygon that surrounds the shop
                    vec3(0.0, 0.0, 0.0),
                    vec3(0.0, 0.0, 0.0),
                    vec3(0.0, 0.0, 0.0),
                    vec3(0.0, 0.0, 0.0),
                },
                size = vec3(0.0, 0.0, 0.0), -- Size of the vehicles zones (x, y, z)
                targetDistance = 1, -- Defines targeting distance. Only works if useTarget is enabled
            },
            blip = {
                label = '', -- Blip label
                coords = vec3(0.0, 0.0, 0.0), -- Blip coordinates
                show = true, -- Enables/disables the blip being shown
                sprite = 0, -- Blip sprite
                color = 0, -- Blip color
            },
            categories = { -- Categories available to browse
                sedans = 'Sedans',
                coupes = 'Coupes',
                suvs = 'SUVs',
                offroad = 'Offroad',
            },
            testDrive = {
                limit = 5.0, -- Time in minutes allotted for the test drive
                spawn = vec4(0.0, 0.0, 0.0, 0.0), -- Spawn location for the test drive
            },
            returnLocation = vec3(0.0, -1082.58, 26.68), -- Location to return vehicle only if the vehicleshop is managed
            vehicleSpawn = vec4(0.0, 0.0, 0.0, 0.0), -- Spawn location when vehicle is purchased
            showroomVehicles = {
                [1] = {
                    coords = vec4(0.0, 0.0, 0.0, 0.0), -- where the vehicle will spawn on display
                    vehicle = '', -- Model name of display vehicle. Is dynamically changed when swapping vehicles
                },
                [2] = {
                    coords = vec4(0.0, 0.0, 0.0, 0.0), -- where the vehicle will spawn on display
                    vehicle = '', -- Model name of display vehicle. Is dynamically changed when swapping vehicles
                },
            },
        },]]--
        pdm = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-32.900001525879, -1108.9000244141, 27.45),
                    vec3(-59.849998474121, -1099.0999755859, 27.45),
                    vec3(-52.25, -1078.3000488281, 27.45),
                    vec3(-25.299999237061, -1088.0999755859, 27.45),
                },
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            blip = {
                label = 'Premium Deluxe Motorsport',
                coords = vec3(-45.67, -1098.34, 26.42),
                show = true,
                sprite = 326,
                color = 3,
            },
            categories = {
                sportsclassics = 'Sports Classics',
                sedans = 'Sedans',
                coupes = 'Coupes',
                suvs = 'SUVs',
                offroad = 'Offroad',
                muscle = 'Muscle',
                compacts = 'Compacts',
                motorcycles = 'Motorcycles',
                vans = 'Vans',
                cycles = 'Bicycles'
            },
            testDrive = {
                limit = 5.0,
                spawn = vec4(-7.24, -1084.81, 26.87, 114.26),
            },
            returnLocation = vec3(-16.64, -1079.87, 26.56),
            vehicleSpawn = vec4(-23.6, -1094.4, 27.0, 340.0),
            showroomVehicles = {
                [1] = {coords = vec4(-37.05, -1093.3, 26.0, 69.5), vehicle = 'adder'},
                [2] = {coords = vec4(-42.35, -1101.35, 26.0, 294.5), vehicle = 'schafter2'},
                [3] = {coords = vec4(-47.5, -1092.0, 26.0, 66.5), vehicle = 'comet2'},
                [4] = {coords = vec4(-54.65, -1096.85, 26.0, 254.5), vehicle = 'vigero'},
                [5] = {coords = vec4(-49.9, -1083.75, 26.0, 165.0), vehicle = 't20'},
            },
        },

        luxury = {
            type = 'managed',
            job = 'cardealer',
            zone = {
                shape = {
                    vec3(-1260.6973876953, -349.21334838867, 36.91),
                    vec3(-1268.6248779297, -352.87365722656, 36.91),
                    vec3(-1274.1533203125, -358.29794311523, 36.91),
                    vec3(-1273.8425292969, -362.73715209961, 36.91),
                    vec3(-1270.5701904297, -368.6716003418, 36.91),
                    vec3(-1266.0561523438, -375.14080810547, 36.91),
                    vec3(-1244.3684082031, -362.70278930664, 36.91),
                    vec3(-1249.8704833984, -352.03326416016, 36.91),
                    vec3(-1252.9503173828, -345.85726928711, 36.91)
                },
                size = vec3(3, 3, 4),
                targetDistance = 1,
            },
            blip = {
                label = 'Luxury Vehicle Shop',
                coords = vec3(-1255.6, -361.16, 36.91),
                show = true,
                sprite = 326,
                color = 3,
            },
            categories = {
                super = 'Super',
                sports = 'Sports'
            },
            testDrive = {
                limit = 5.0,
                spawn = vec4(-1232.81, -347.99, 37.33, 23.28),
            },
            returnLocation = vec3(-1231.46, -349.86, 37.33),
            vehicleSpawn = vec4(-1231.46, -349.86, 37.33, 26.61),
            showroomVehicles = {
                [1] = {coords = vec4(-1265.31, -354.44, 35.91, 205.08), vehicle = 'italirsx'},
                [2] = {coords = vec4(-1270.06, -358.55, 35.91, 247.08), vehicle = 'italigtb'},
                [3] = {coords = vec4(-1269.21, -365.03, 35.91, 297.12), vehicle = 'nero'},
                [4] = {coords = vec4(-1252.07, -364.2, 35.91, 56.44), vehicle = 'bati'},
                [5] = {coords = vec4(-1255.49, -365.91, 35.91, 55.63), vehicle = 'carbonrs'},
                [6] = {coords = vec4(-1249.21, -362.97, 35.91, 53.24), vehicle = 'hexer'},
            }
        },

        boats = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-729.39, -1315.84, 0),
                    vec3(-766.81, -1360.11, 0),
                    vec3(-754.21, -1371.49, 0),
                    vec3(-716.94, -1326.88, 0)
                },
                size = vec3(8, 8, 6),
                targetDistance = 10,
            },
            blip = {
                label = 'Marina Shop',
                coords = vec3(-738.25, -1334.38, 1.6),
                show = true,
                sprite = 410,
                color = 3,
            },
            categories = {
                boats = 'Boats'
            },
            testDrive = {
                limit = 5.0,
                spawn = vec4(-722.23, -1351.98, 0.14, 135.33),
            },
            returnLocation = vec3(-714.34, -1343.31, 0.0),
            vehicleSpawn = vec4(-727.87, -1353.1, -0.17, 137.09),
            showroomVehicles = {
                [1] = {coords = vec4(-727.05, -1326.59, -0.50, 229.5), vehicle = 'seashark'},
                [2] = {coords = vec4(-732.84, -1333.5, -0.50, 229.5), vehicle = 'dinghy'},
                [3] = {coords = vec4(-737.84, -1340.83, -0.50, 229.5), vehicle = 'speeder'},
                [4] = {coords = vec4(-741.53, -1349.7, -0.50, 229.5), vehicle = 'marquis'},
            },
        },

        air = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-1607.58, -3141.7, 12.99),
                    vec3(-1672.54, -3103.87, 12.99),
                    vec3(-1703.49, -3158.02, 12.99),
                    vec3(-1646.03, -3190.84, 12.99)
                },
                size = vec3(10, 10, 8),
                targetDistance = 5,
            },
            blip = {
                label = 'Air Shop',
                coords = vec3(-1652.76, -3143.4, 13.99),
                show = true,
                sprite = 251,
                color = 3,
            },
            categories = {
                helicopters = 'Helicopters',
                planes = 'Planes'
            },
            testDrive = {
                limit = 5.0,
                spawn = vec4(-1625.19, -3103.47, 13.94, 330.28),
            },
            returnLocation = vec3(-1628.44, -3104.7, 13.94),
            vehicleSpawn = vec4(-1617.49, -3086.17, 13.94, 329.2),
            showroomVehicles = {
                [1] = {coords = vec4(-1651.36, -3162.66, 12.99, 346.89), vehicle = 'volatus'},
                [2] = {coords = vec4(-1668.53, -3152.56, 12.99, 303.22), vehicle = 'luxor2'},
                [3] = {coords = vec4(-1632.02, -3144.48, 12.99, 31.08), vehicle = 'nimbus'},
                [4] = {coords = vec4(-1663.74, -3126.32, 12.99, 275.03), vehicle = 'frogger'},
            },
        },
    },
}