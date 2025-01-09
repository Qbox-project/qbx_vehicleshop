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
            -- super = { 'pdm', 'luxury' },
        },

        models = {
            -- zentorno = { 'pdm', 'luxury' },

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

    ---@type table<string, Dealership>
    shops = {
        pdm = {
            type = 'free-use',
            zone = {
                shape = {
                    vec3(-56.727394104004, -1086.2325439453, 26.0),
                    vec3(-60.612808227539, -1096.7795410156, 26.0),
                    vec3(-58.26834487915, -1100.572265625, 26.0),
                    vec3(-35.927803039551, -1109.0034179688, 26.0),
                    vec3(-34.427627563477, -1108.5111083984, 26.0),
                    vec3(-32.02657699585, -1101.5877685547, 26.0),
                    vec3(-33.342102050781, -1101.0377197266, 26.0),
                    vec3(-31.292987823486, -1095.3717041016, 26.0)
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
                endBehavior = 'return'
            },
            returnLocation = vec3(-32.77, -1095.75, 26.42),
            vehicleSpawns = {
                vec4(-61.35, -1110.31, 25.86, 71.01),
                vec4(-59.61, -1104.74, 25.85, 70.13),
                vec4(-52.96, -1113.49, 25.87, 71.53),
                vec4(-52.34, -1107.93, 25.87, 71.63),
                vec4(-44.27, -1116.36, 25.87, 71.7),
                vec4(-41.75, -1111.49, 25.87, 71.5),
            },
            showroomVehicles = {
                { coords = vec4(-45.65, -1093.66, 25.44, 69.5), vehicle = 'asbo' },
                { coords = vec4(-48.27, -1101.86, 25.44, 294.5), vehicle = 'schafter2' },
                { coords = vec4(-39.6, -1096.01, 25.44, 66.5), vehicle = 'greenwood' },
                { coords = vec4(-51.21, -1096.77, 25.44, 254.5), vehicle = 'vigero' },
                { coords = vec4(-40.18, -1104.13, 25.44, 338.5), vehicle = 'impaler' },
                { coords = vec4(-43.31, -1099.02, 25.44, 52.5), vehicle = 'bati' },
                { coords = vec4(-50.66, -1093.05, 25.44, 222.5), vehicle = 'bati' },
                { coords = vec4(-44.28, -1102.47, 25.44, 298.5), vehicle = 'bati' },
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
                endBehavior = 'return'
            },
            returnLocation = vec3(-1231.46, -349.86, 37.33),
            vehicleSpawns = {
                vec4(-1231.46, -349.86, 37.33, 26.61),
            },
            showroomVehicles = {
                { coords = vec4(-1265.31, -354.44, 35.91, 205.08), vehicle = 'italirsx' },
                { coords = vec4(-1270.06, -358.55, 35.91, 247.08), vehicle = 'italigtb' },
                { coords = vec4(-1269.21, -365.03, 35.91, 297.12), vehicle = 'nero' },
                { coords = vec4(-1252.07, -364.2, 35.91, 56.44), vehicle = 'nero2' },
                { coords = vec4(-1255.49, -365.91, 35.91, 55.63), vehicle = 'osiris' },
                { coords = vec4(-1249.21, -362.97, 35.91, 53.24), vehicle = 'penetrator' },
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
                endBehavior = 'return'
            },
            returnLocation = vec3(-714.34, -1343.31, 0.0),
            vehicleSpawns = {
                vec4(-727.87, -1353.1, -0.17, 137.09),
            },
            showroomVehicles = {
                { coords = vec4(-727.05, -1326.59, -0.50, 229.5), vehicle = 'seashark' },
                { coords = vec4(-732.84, -1333.5, -0.50, 229.5), vehicle = 'dinghy' },
                { coords = vec4(-737.84, -1340.83, -0.50, 229.5), vehicle = 'speeder' },
                { coords = vec4(-741.53, -1349.7, -0.50, 229.5), vehicle = 'marquis' },
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
                endBehavior = 'return'
            },
            returnLocation = vec3(-1628.44, -3104.7, 13.94),
            vehicleSpawns = {
                vec4(-1617.49, -3086.17, 13.94, 329.2),
            },
            showroomVehicles = {
                { coords = vec4(-1651.36, -3162.66, 12.99, 346.89), vehicle = 'volatus' },
                { coords = vec4(-1668.53, -3152.56, 12.99, 303.22), vehicle = 'luxor2' },
                { coords = vec4(-1632.02, -3144.48, 12.99, 31.08), vehicle = 'nimbus' },
                { coords = vec4(-1663.74, -3126.32, 12.99, 275.03), vehicle = 'frogger' },
            },
        },
    },
}