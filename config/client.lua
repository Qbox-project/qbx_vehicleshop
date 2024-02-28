return {
    useTarget = false,
    debugPoly = false,
    enableFreeUseBuy = true, -- Allows players to buy from NPC shops
    requestModelTimeout = 5000, -- load model timeout for oxlib
    enableTestDrive = true,
    
    finance = {
        enable = true, -- Enables the financing system. Turning this off does not affect already financed vehicles
        commissionRate = 0.05, -- Percent that goes to sales person from a finance sale 5%
        zone = vec3(-29.53, -1103.67, 26.42), -- Where the finance menu is located
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
                spawn = vec4(-7.84, -1081.35, 26.67, 121.83),
            },
            returnLocation = vec3(-44.74, -1082.58, 26.68),
            vehicleSpawn = vec4(-31.69, -1090.78, 26.42, 328.79),
            showroomVehicles = {
                [1] = {coords = vec4(-45.65, -1093.66, 25.44, 69.5), vehicle = 'adder'},
                [2] = {coords = vec4(-48.27, -1101.86, 25.44, 294.5), vehicle = 'schafter2'},
                [3] = {coords = vec4(-39.6, -1096.01, 25.44, 66.5), vehicle = 'comet2'},
                [4] = {coords = vec4(-51.21, -1096.77, 25.44, 254.5), vehicle = 'vigero'},
                [5] = {coords = vec4(-40.18, -1104.13, 25.44, 338.5), vehicle = 't20'},
                [6] = {coords = vec4(-43.31, -1099.02, 25.44, 52.5), vehicle = 'bati'},
                [7] = {coords = vec4(-50.66, -1093.05, 25.44, 222.5), vehicle = 'bati'},
                [8] = {coords = vec4(-44.28, -1102.47, 25.44, 298.5), vehicle = 'bati'}
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
    
    vehicles = {
        asbo = {
            shop = 'pdm',
        },
        blista = {
            shop = 'pdm',
        },
        brioso = {
            shop = 'pdm',
        },
        club = {
            shop = 'pdm',
        },
        dilettante = {
            shop = 'pdm',
        },
        dilettante2 = {
            shop = 'pdm',
        },
        kanjo = {
            shop = 'pdm',
        },
        issi2 = {
            shop = 'pdm',
        },
        issi3 = {
            shop = 'pdm',
        },
        issi4 = {
            shop = 'pdm',
        },
        issi5 = {
            shop = 'pdm',
        },
        issi6 = {
            shop = 'pdm',
        },
        panto = {
            shop = 'pdm',
        },
        prairie = {
            shop = 'pdm',
        },
        rhapsody = {
            shop = 'pdm',
        },
        brioso2 = {
            shop = 'pdm',
        },
        weevil = {
            shop = 'pdm',
        },

        --- Coupes
        cogcabrio = {
            shop = 'pdm',
        },
        exemplar = {
            shop = 'pdm',
        },
        f620 = {
            shop = 'pdm',
        },
        felon = {
            shop = 'pdm',
        },
        felon2 = {
            shop = 'pdm',
        },
        jackal = {
            shop = 'pdm',
        },
        oracle = {
            shop = 'pdm',
        },
        oracle2 = {
            shop = 'pdm',
        },
        sentinel = {
            shop = 'pdm',
        },
        sentinel2 = {
            shop = 'pdm',
        },
        windsor = {
            shop = 'pdm',
        },
        windsor2 = {
            shop = 'pdm',
        },
        zion = {
            shop = 'pdm',
        },
        zion2 = {
            shop = 'pdm',
        },
        previon = {
            shop = 'pdm',
        },
        champion = {
            shop = 'pdm',
        },
        ignus = {
            shop = 'pdm',
        },
        zeno = {
            shop = 'pdm',
        },

        --- Cycles
        bmx = {
            shop = 'pdm',
        },
        cruiser = {
            shop = 'pdm',
        },
        fixter = {
            shop = 'pdm',
        },
        scorcher = {
            shop = 'pdm',
        },
        tribike = {
            shop = 'pdm',
        },
        tribike2 = {
            shop = 'pdm',
        },
        tribike3 = {
            shop = 'pdm',
        },

        --- Motorcycles
        akuma = {
            shop = 'pdm',
        },
        avarus = {
            shop = 'pdm',
        },
        bagger = {
            shop = 'pdm',
        },
        bati = {
            shop = 'pdm',
        },
        bati2 = {
            shop = 'pdm',
        },
        bf400 = {
            shop = 'pdm',
        },
        carbonrs = {
            shop = 'pdm',
        },
        chimera = {
            shop = 'pdm',
        },
        cliffhanger = {
            shop = 'pdm',
        },
        daemon = {
            shop = 'pdm',
        },
        daemon2 = {
            shop = 'pdm',
        },
        defiler = {
            shop = 'pdm',
        },
        deathbike = {
            shop = 'pdm',
        },
        deathbike2 = {
            shop = 'pdm',
        },
        deathbike3 = {
            shop = 'pdm',
        },
        diablous = {
            shop = 'pdm',
        },
        diablous2 = {
            shop = 'pdm',
        },
        double = {
            shop = 'pdm',
        },
        enduro = {
            shop = 'pdm',
        },
        esskey = {
            shop = 'pdm',
        },
        faggio = {
            shop = 'pdm',
        },
        faggio2 = {
            shop = 'pdm',
        },
        faggio3 = {
            shop = 'pdm',
        },
        fcr = {
            shop = 'pdm',
        },
        fcr2 = {
            shop = 'pdm',
        },
        gargoyle = {
            shop = 'pdm',
        },
        hakuchou = {
            shop = 'pdm',
        },
        hakuchou2 = {
            shop = 'pdm',
        },
        hexer = {
            shop = 'pdm',
        },
        innovation = {
            shop = 'pdm',
        },
        lectro = {
            shop = 'pdm',
        },
        manchez = {
            shop = 'pdm',
        },
        nemesis = {
            shop = 'pdm',
        },
        nightblade = {
            shop = 'pdm',
        },
        oppressor = {
            shop = 'luxury',
        },
        pcj = {
            shop = 'pdm',
        },
        ratbike = {
            shop = 'pdm',
        },
        ruffian = {
            shop = 'pdm',
        },
        sanchez = {
            shop = 'pdm',
        },
        sanchez2 = {
            shop = 'pdm',
        },
        sanctus = {
            shop = 'pdm',
        },
        shotaro = {
            shop = 'pdm',
        },
        sovereign = {
            shop = 'pdm',
        },
        stryder = {
            shop = 'pdm',
        },
        thrust = {
            shop = 'pdm',
        },
        vader = {
            shop = 'pdm',
        },
        vindicator = {
            shop = 'pdm',
        },
        vortex = {
            shop = 'pdm',
        },
        wolfsbane = {
            shop = 'pdm',
        },
        zombiea = {
            shop = 'pdm',
        },
        zombieb = {
            shop = 'pdm',
        },
        manchez2 = {
            shop = 'pdm',
        },
        shinobi = {
            shop = 'pdm',
        },
        reever = {
            shop = 'pdm',
        },

        --- Muscle
        blade = {
            shop = 'pdm',
        },
        buccaneer = {
            shop = 'pdm',
        },
        buccaneer2 = {
            shop = 'pdm',
        },
        chino = {
            shop = 'pdm',
        },
        chino2 = {
            shop = 'pdm',
        },
        clique = {
            shop = 'pdm',
        },
        coquette3 = {
            shop = 'pdm',
        },
        deviant = {
            shop = 'pdm',
        },
        dominator = {
            shop = 'pdm',
        },
        dominator2 = {
            shop = 'pdm',
        },
        dominator3 = {
            shop = 'pdm',
        },
        dominator4 = {
            shop = 'pdm',
        },
        dominator7 = {
            shop = 'pdm',
        },
        dominator8 = {
            shop = 'pdm',
        },
        dukes = {
            shop = 'pdm',
        },
        dukes2 = {
            shop = 'pdm',
        },
        dukes3 = {
            shop = 'pdm',
        },
        faction = {
            shop = 'pdm',
        },
        faction2 = {
            shop = 'pdm',
        },
        faction3 = {
            shop = 'pdm',
        },
        ellie = {
            shop = 'pdm',
        },
        gauntlet = {
            shop = 'pdm',
        },
        gauntlet2 = {
            shop = 'pdm',
        },
        gauntlet3 = {
            shop = 'pdm',
        },
        gauntlet4 = {
            shop = 'pdm',
        },
        gauntlet5 = {
            shop = 'pdm',
        },
        hermes = {
            shop = 'pdm',
        },
        hotknife = {
            shop = 'pdm',
        },
        hustler = {
            shop = 'pdm',
        },
        impaler = {
            shop = 'pdm',
        },
        impaler2 = {
            shop = 'pdm',
        },
        impaler3 = {
            shop = 'pdm',
        },
        impaler4 = {
            shop = 'pdm',
        },
        imperator = {
            shop = 'pdm',
        },
        imperator2 = {
            shop = 'pdm',
        },
        imperator3 = {
            shop = 'pdm',
        },
        lurcher = {
            shop = 'pdm',
        },
        moonbeam = {
            shop = 'pdm',
        },
        moonbeam2 = {
            shop = 'pdm',
        },
        nightshade = {
            shop = 'pdm',
        },
        peyote2 = {
            shop = 'pdm',
        },
        phoenix = {
            shop = 'pdm',
        },
        picador = {
            shop = 'pdm',
        },
        ratloader2 = {
            shop = 'pdm',
        },
        ruiner = {
            shop = 'pdm',
        },
        ruiner2 = {
            shop = 'pdm',
        },
        sabregt = {
            shop = 'pdm',
        },
        sabregt2 = {
            shop = 'pdm',
        },
        slamvan = {
            shop = 'pdm',
        },
        slamvan2 = {
            shop = 'pdm',
        },
        slamvan3 = {
            shop = 'pdm',
        },
        stalion = {
            shop = 'pdm',
        },
        stalion2 = {
            shop = 'pdm',
        },
        tampa = {
            shop = 'pdm',
        },
        tulip = {
            shop = 'pdm',
        },
        vamos = {
            shop = 'pdm',
        },
        vigero = {
            shop = 'pdm',
        },
        virgo = {
            shop = 'pdm',
        },
        virgo2 = {
            shop = 'pdm',
        },
        virgo3 = {
            shop = 'pdm',
        },
        voodoo = {
            shop = 'pdm',
        },
        yosemite = {
            shop = 'pdm',
        },
        yosemite2 = {
            shop = 'pdm',
        },
        yosemite3 = {
            shop = 'pdm',
        },
        buffalo4 = {
            shop = 'pdm',
        },

        --- Off-Road
        bfinjection = {
            shop = 'pdm',
        },
        bifta = {
            shop = 'pdm',
        },
        blazer = {
            shop = 'pdm',
        },
        blazer2 = {
            shop = 'pdm',
        },
        blazer3 = {
            shop = 'pdm',
        },
        blazer4 = {
            shop = 'pdm',
        },
        blazer5 = {
            shop = 'pdm',
        },
        brawler = {
            shop = 'pdm',
        },
        caracara = {
            shop = 'pdm',
        },
        caracara2 = {
            shop = 'pdm',
        },
        dubsta3 = {
            shop = 'pdm',
        },
        dune = {
            shop = 'pdm',
        },
        everon = {
            shop = 'pdm',
        },
        freecrawler = {
            shop = 'pdm',
        },
        hellion = {
            shop = 'pdm',
        },
        kalahari = {
            shop = 'pdm',
        },
        kamacho = {
            shop = 'pdm',
        },
        mesa3 = {
            shop = 'pdm',
        },
        outlaw = {
            shop = 'pdm',
        },
        rancherxl = {
            shop = 'pdm',
        },
        rebel2 = {
            shop = 'pdm',
        },
        riata = {
            shop = 'pdm',
        },
        sandking = {
            shop = 'pdm',
        },
        sandking2 = {
            shop = 'pdm',
        },
        trophytruck = {
            shop = 'pdm',
        },
        trophytruck2 = {
            shop = 'pdm',
        },
        vagrant = {
            shop = 'pdm',
        },
        verus = {
            shop = 'pdm',
        },
        winky = {
            shop = 'pdm',
        },

        --- SUVs
        baller = {
            shop = 'pdm',
        },
        baller2 = {
            shop = 'pdm',
        },
        baller3 = {
            shop = 'pdm',
        },
        baller4 = {
            shop = 'pdm',
        },
        baller5 = {
            shop = 'pdm',
        },
        baller6 = {
            shop = 'pdm',
        },
        bjxl = {
            shop = 'pdm',
        },
        cavalcade = {
            shop = 'pdm',
        },
        cavalcade2 = {
            shop = 'pdm',
        },
        contender = {
            shop = 'pdm',
        },
        dubsta = {
            shop = 'pdm',
        },
        dubsta2 = {
            shop = 'pdm',
        },
        fq2 = {
            shop = 'pdm',
        },
        granger = {
            shop = 'pdm',
        },
        gresley = {
            shop = 'pdm',
        },
        habanero = {
            shop = 'pdm',
        },
        huntley = {
            shop = 'pdm',
        },
        landstalker = {
            shop = 'pdm',
        },
        landstalker2 = {
            shop = 'pdm',
        },
        mesa = {
            shop = 'pdm',
        },
        novak = {
            shop = 'pdm',
        },
        patriot = {
            shop = 'pdm',
        },
        radi = {
            shop = 'pdm',
        },
        rebla = {
            shop = 'pdm',
        },
        rocoto = {
            shop = 'pdm',
        },
        seminole = {
            shop = 'pdm',
        },
        seminole2 = {
            shop = 'pdm',
        },
        serrano = {
            shop = 'pdm',
        },
        toros = {
            shop = 'pdm',
        },
        xls = {
            shop = 'pdm',
        },
        granger2 = {
            shop = 'pdm',
        },

        --- Sedans
        asea = {
            shop = 'pdm',
        },
        asterope = {
            shop = 'pdm',
        },
        cog55 = {
            shop = 'pdm',
        },
        cognoscenti = {
            shop = 'pdm',
        },
        emperor = {
            shop = 'pdm',
        },
        fugitive = {
            shop = 'pdm',
        },
        glendale = {
            shop = 'pdm',
        },
        glendale2 = {
            shop = 'pdm',
        },
        ingot = {
            shop = 'pdm',
        },
        intruder = {
            shop = 'pdm',
        },
        premier = {
            shop = 'pdm',
        },
        primo = {
            shop = 'pdm',
        },
        primo2 = {
            shop = 'pdm',
        },
        regina = {
            shop = 'pdm',
        },
        stafford = {
            shop = 'pdm',
        },
        stanier = {
            shop = 'pdm',
        },
        stratum = {
            shop = 'pdm',
        },
        stretch = {
            shop = 'pdm',
        },
        superd = {
            shop = 'pdm',
        },
        surge = {
            shop = 'pdm',
        },
        tailgater = {
            shop = 'pdm',
        },
        warrener = {
            shop = 'pdm',
        },
        washington = {
            shop = 'pdm',
        },
        tailgater2 = {
            shop = 'pdm',
        },
        cinquemila = {
            shop = 'pdm',
        },
        iwagen = {
            shop = 'pdm',
        },
        astron = {
            shop = 'pdm',
        },
        baller7 = {
            shop = 'pdm',
        },
        comet7 = {
            shop = 'pdm',
        },
        deity = {
            shop = 'pdm',
        },
        jubilee = {
            shop = 'pdm',
        },
        patriot3 = {
            shop = 'pdm',
        },

        --- Sports
        alpha = {
            shop = 'luxury',
        },
        banshee = {
            shop = 'luxury',
        },
        bestiagts = {
            shop = 'luxury',
        },
        blista2 = {
            shop = 'pdm',
        },
        blista3 = {
            shop = 'pdm',
        },
        buffalo = {
            shop = 'luxury',
        },
        buffalo2 = {
            shop = 'luxury',
        },
        carbonizzare = {
            shop = 'luxury',
        },
        comet2 = {
            shop = 'luxury',
        },
        comet3 = {
            shop = 'luxury',
        },
        comet4 = {
            shop = 'luxury',
        },
        comet5 = {
            shop = 'luxury',
        },
        coquette = {
            shop = 'luxury',
        },
        coquette2 = {
            shop = 'pdm',
        },
        coquette4 = {
            shop = 'luxury',
        },
        drafter = {
            shop = 'luxury',
        },
        deveste = {
            shop = 'luxury',
        },
        elegy = {
            shop = 'luxury',
        },
        elegy2 = {
            shop = 'luxury',
        },
        feltzer2 = {
            shop = 'luxury',
        },
        flashgt = {
            shop = 'luxury',
        },
        furoregt = {
            shop = 'luxury',
        },
        futo = {
            shop = 'pdm',
        },
        gb200 = {
            shop = 'luxury',
        },
        komoda = {
            shop = 'luxury',
        },
        imorgon = {
            shop = 'luxury',
        },
        issi7 = {
            shop = 'pdm',
        },
        italigto = {
            shop = 'luxury',
        },
        jugular = {
            shop = 'luxury',
        },
        jester = {
            shop = 'luxury',
        },
        jester2 = {
            shop = 'luxury',
        },
        jester3 = {
            shop = 'luxury',
        },
        khamelion = {
            shop = 'luxury',
        },
        kuruma = {
            shop = 'luxury',
        },
        kuruma2 = {
            shop = 'luxury',
        },
        locust = {
            shop = 'luxury',
        },
        lynx = {
            shop = 'luxury',
        },
        massacro = {
            shop = 'luxury',
        },
        massacro2 = {
            shop = 'luxury',
        },
        neo = {
            shop = 'luxury',
        },
        neon = {
            shop = 'luxury',
        },
        ninef = {
            shop = 'luxury',
        },
        ninef2 = {
            shop = 'luxury',
        },
        omnis = {
            shop = 'luxury',
        },
        paragon = {
            shop = 'luxury',
        },
        pariah = {
            shop = 'luxury',
        },
        penumbra = {
            shop = 'luxury',
        },
        penumbra2 = {
            shop = 'luxury',
        },
        rapidgt = {
            shop = 'luxury',
        },
        rapidgt2 = {
            shop = 'luxury',
        },
        raptor = {
            shop = 'luxury',
        },
        revolter = {
            shop = 'luxury',
        },
        ruston = {
            shop = 'luxury',
        },
        schafter2 = {
            shop = 'pdm',
        },
        schafter3 = {
            shop = 'luxury',
        },
        schafter4 = {
            shop = 'luxury',
        },
        schlagen = {
            shop = 'luxury',
        },
        schwarzer = {
            shop = 'luxury',
        },
        sentinel3 = {
            shop = 'pdm',
        },
        seven70 = {
            shop = 'luxury',
        },
        specter = {
            shop = 'luxury',
        },
        streiter = {
            shop = 'luxury',
        },
        sugoi = {
            shop = 'luxury',
        },
        sultan = {
            shop = 'luxury',
        },
        sultan2 = {
            shop = 'luxury',
        },
        surano = {
            shop = 'luxury',
        },
        tampa2 = {
            shop = 'pdm',
        },
        tropos = {
            shop = 'luxury',
        },
        verlierer2 = {
            shop = 'luxury',
        },
        vstr = {
            shop = 'luxury',
        },
        italirsx = {
            shop = 'luxury',
        },
        zr350 = {
            shop = 'luxury',
        },
        calico = {
            shop = 'luxury',
        },
        futo2 = {
            shop = 'luxury',
        },
        euros = {
            shop = 'luxury',
        },
        jester4 = {
            shop = 'luxury',
        },
        remus = {
            shop = 'luxury',
        },
        comet6 = {
            shop = 'luxury',
        },
        growler = {
            shop = 'luxury',
        },
        vectre = {
            shop = 'luxury',
        },
        cypher = {
            shop = 'luxury',
        },
        sultan3 = {
            shop = 'luxury',
        },
        rt3000 = {
            shop = 'luxury',
        },

        --- Sports Classic
        ardent = {
            shop = 'pdm',
        },
        btype = {
            shop = 'pdm',
        },
        btype2 = {
            shop = 'pdm',
        },
        btype3 = {
            shop = 'pdm',
        },
        casco = {
            shop = 'pdm',
        },
        cheetah2 = {
            shop = 'luxury',
        },
        deluxo = {
            shop = 'pdm',
        },
        dynasty = {
            shop = 'pdm',
        },
        fagaloa = {
            shop = 'pdm',
        },
        feltzer3 = {
            shop = 'pdm',
        },
        gt500 = {
            shop = 'pdm',
        },
        infernus2 = {
            shop = 'pdm',
        },
        jb700 = {
            shop = 'pdm',
        },
        jb7002 = {
            shop = 'pdm',
        },
        mamba = {
            shop = 'pdm',
        },
        manana = {
            shop = 'pdm',
        },
        manana2 = {
            shop = 'pdm',
        },
        michelli = {
            shop = 'pdm',
        },
        monroe = {
            shop = 'pdm',
        },
        nebula = {
            shop = 'pdm',
        },
        peyote = {
            shop = 'pdm',
        },
        peyote3 = {
            shop = 'pdm',
        },
        pigalle = {
            shop = 'pdm',
        },
        rapidgt3 = {
            shop = 'pdm',
        },
        retinue = {
            shop = 'pdm',
        },
        retinue2 = {
            shop = 'pdm',
        },
        savestra = {
            shop = 'pdm',
        },
        stinger = {
            shop = 'pdm',
        },
        stingergt = {
            shop = 'pdm',
        },
        stromberg = {
            shop = 'pdm',
        },
        swinger = {
            shop = 'pdm',
        },
        torero = {
            shop = 'pdm',
        },
        tornado = {
            shop = 'pdm',
        },
        tornado2 = {
            shop = 'pdm',
        },
        tornado5 = {
            shop = 'pdm',
        },
        turismo2 = {
            shop = 'pdm',
        },
        viseris = {
            shop = 'pdm',
        },
        z190 = {
            shop = 'pdm',
        },
        ztype = {
            shop = 'pdm',
        },
        zion3 = {
            shop = 'pdm',
        },
        cheburek = {
            shop = 'pdm',
        },
        toreador = {
            shop = 'pdm',
        },

        --- Super
        adder = {
            shop = 'luxury',
        },
        autarch = {
            shop = 'luxury',
        },
        banshee2 = {
            shop = 'luxury',
        },
        bullet = {
            shop = 'luxury',
        },
        cheetah = {
            shop = 'luxury',
        },
        cyclone = {
            shop = 'luxury',
        },
        entity2 = {
            shop = 'luxury',
        },
        entityxf = {
            shop = 'luxury',
        },
        emerus = {
            shop = 'luxury',
        },
        fmj = {
            shop = 'luxury',
        },
        furia = {
            shop = 'luxury',
        },
        gp1 = {
            shop = 'luxury',
        },
        infernus = {
            shop = 'luxury',
        },
        italigtb = {
            shop = 'luxury',
        },
        italigtb2 = {
            shop = 'luxury',
        },
        krieger = {
            shop = 'luxury',
        },
        le7b = {
            shop = 'luxury',
        },
        nero = {
            shop = 'luxury',
        },
        nero2 = {
            shop = 'luxury',
        },
        osiris = {
            shop = 'luxury',
        },
        penetrator = {
            shop = 'luxury',
        },
        pfister811 = {
            shop = 'luxury',
        },
        prototipo = {
            shop = 'luxury',
        },
        reaper = {
            shop = 'luxury',
        },
        s80 = {
            shop = 'luxury',
        },
        sc1 = {
            shop = 'luxury',
        },
        sheava = {
            shop = 'luxury',
        },
        sultanrs = {
            shop = 'luxury',
        },
        t20 = {
            shop = 'luxury',
        },
        taipan = {
            shop = 'luxury',
        },
        tempesta = {
            shop = 'luxury',
        },
        tezeract = {
            shop = 'luxury',
        },
        thrax = {
            shop = 'luxury',
        },
        tigon = {
            shop = 'luxury',
        },
        turismor = {
            shop = 'luxury',
        },
        tyrant = {
            shop = 'luxury',
        },
        tyrus = {
            shop = 'luxury',
        },
        vacca = {
            shop = 'luxury',
        },
        vagner = {
            shop = 'luxury',
        },
        visione = {
            shop = 'luxury',
        },
        voltic = {
            shop = 'luxury',
        },
        voltic2 = {
            shop = 'luxury',
        },
        xa21 = {
            shop = 'luxury',
        },
        zentorno = {
            shop = 'luxury',
        },
        zorrusso = {
            shop = 'luxury',
        },

        --- Vans
        bison = {
            shop = 'pdm',
        },
        bobcatxl = {
            shop = 'pdm',
        },
        burrito3 = {
            shop = 'pdm',
        },
        gburrito2 = {
            shop = 'pdm',
        },
        rumpo = {
            shop = 'pdm',
        },
        journey = {
            shop = 'pdm',
        },
        minivan = {
            shop = 'pdm',
        },
        minivan2 = {
            shop = 'pdm',
        },
        paradise = {
            shop = 'pdm',
        },
        rumpo3 = {
            shop = 'pdm',
        },
        speedo = {
            shop = 'pdm',
        },
        speedo4 = {
            shop = 'pdm',
        },
        surfer = {
            shop = 'pdm',
        },
        youga3 = {
            shop = 'pdm',
        },
        youga = {
            shop = 'pdm',
        },
        youga2 = {
            shop = 'pdm',
        },
        youga4 = {
            shop = 'pdm',
        },
        mule5 = {
            shop = 'pdm',
        },

        --- Utility
        sadler = {
            shop = 'pdm',
        },
        guardian = {
            shop = 'pdm',
        },
        slamtruck = {
            shop = 'pdm',
        },
        warrener2 = {
            shop = 'pdm',
        },

        --- Boats
        squalo = {
            shop = 'boats',
        },
        marquis = {
            shop = 'boats',
        },
        seashark = {
            shop = 'boats',
        },
        seashark2 = {
            shop = 'boats',
        },
        seashark3 = {
            shop = 'boats',
        },
        jetmax = {
            shop = 'boats',
        },
        tropic = {
            shop = 'boats',
        },
        tropic2 = {
            shop = 'boats',
        },
        dinghy = {
            shop = 'boats',
        },
        dinghy2 = {
            shop = 'boats',
        },
        dinghy3 = {
            shop = 'boats',
        },
        dinghy4 = {
            shop = 'boats',
        },
        suntrap = {
            shop = 'boats',
        },
        speeder = {
            shop = 'boats',
        },
        speeder2 = {
            shop = 'boats',
        },
        longfin = {
            shop = 'boats',
        },
        toro = {
            shop = 'boats',
        },
        toro2 = {
            shop = 'boats',
        },

        --- Helicopters
        buzzard2 = {
            shop = 'air',
        },
        frogger = {
            shop = 'air',
        },
        frogger2 = {
            shop = 'air',
        },
        maverick = {
            shop = 'air',
        },
        swift = {
            shop = 'air',
        },
        swift2 = {
            shop = 'air',
        },
        seasparrow = {
            shop = 'air',
        },
        seasparrow2 = {
            shop = 'air',
        },
        seasparrow3 = {
            shop = 'air',
        },
        supervolito = {
            shop = 'air',
        },
        supervolito2 = {
            shop = 'air',
        },
        volatus = {
            shop = 'air',
        },
        havok = {
            shop = 'air',
        },

        --- Planes
        duster = {
            shop = 'air',
        },
        luxor = {
            shop = 'air',
        },
        luxor2 = {
            shop = 'air',
        },
        stunt = {
            shop = 'air',
        },
        mammatus = {
            shop = 'air',
        },
        velum = {
            shop = 'air',
        },
        velum2 = {
            shop = 'air',
        },
        shamal = {
            shop = 'air',
        },
        vestra = {
            shop = 'air',
        },
        dodo = {
            shop = 'air',
        },
        howard = {
            shop = 'air',
        },
        alphaz1 = {
            shop = 'air',
        },
        nimbus = {
            shop = 'air',
        },
        brioso3 = {
            shop = 'pdm',
        },
        conada = {
            shop = 'air',
        },
        corsita = {
            shop = 'luxury',
        },
        draugur = {
            shop = 'pdm',
        },
        greenwood = {
            shop = 'pdm',
        },
        kanjosj = {
            shop = 'pdm',
        },
        lm87 = {
            shop = 'luxury',
        },
        omnisegt = {
            shop = 'luxury',
        },
        postlude = {
            shop = 'pdm',
        },
        rhinehart = {
            shop = 'pdm',
        },
        ruiner4 = {
            shop = 'pdm',
        },
        sentinel4 = {
            shop = 'luxury',
        },
        sm722 = {
            shop = 'luxury',
        },
        tenf = {
            shop = 'luxury',
        },
        tenf2 = {
            shop = 'luxury',
        },
        torero2 = {
            shop = 'luxury',
        },
        vigero2 = {
            shop = 'pdm',
        },
        weevil2 = {
            shop = 'pdm',
        },
    },
}
