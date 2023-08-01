Config = {} --Optional Config for Gabz PDM

-- Using this config will allow you to use Gabz PDM with QBX Vehicleshop
-- This config is optional and is not required to use QBX Vehicleshop however it is recommended if you wish to use Gabz PDM
-- If you wish to use this config,replace it with the config.lua in the root folder
-- If you do not wish to use this config, you can delete this folder

-- Some Screenshots of Gabz PDM with QBX Vehicleshop
-- Overview: https://i.imgur.com/Ec7rLpE.jpeg
-- Purchase Spawn: https://i.imgur.com/JygMaeV.jpeg
-- Finance: https://i.imgur.com/Hqtjlps.jpeg
-- Test Drive Spawn Location: https://i.imgur.com/YSll185.jpeg


Config.UsingTarget = GetConvar('UseTarget', 'false') == 'true'
Config.Commission = 0.10 -- Percent that goes to sales person from a full car sale 10%
Config.EnableFinance = true -- allows financing new vehicles. Turning off does not affect already financed vehicles
Config.EnableFreeUseBuy = true -- allows players to buy from NPC shops
Config.FinanceCommission = 0.05 -- Percent that goes to sales person from a finance sale 5%
Config.FinanceZone = vector3(-32.93, -1097.21, 27.27)-- Where the finance menu is located
Config.PaymentWarning = 10 -- time in minutes that player has to make payment before repo
Config.PaymentInterval = 24 -- time in hours between payment being due
Config.MinimumDown = 10 -- minimum percentage allowed down
Config.MaximumPayments = 24 -- maximum payments allowed
Config.PreventFinanceSelling = false -- allow/prevent players from using /transfervehicle if financed
Config.Shops = {
	pdm = {
		Type = 'free-use', -- no player interaction is required to purchase a car
		Zone = {
			Shape = {
				--polygon that surrounds the shop
				vec3(-32.900001525879, -1108.9000244141, 27.45),
				vec3(-59.849998474121, -1099.0999755859, 27.45),
				vec3(-52.25, -1078.3000488281, 27.45),
				vec3(-25.299999237061, -1088.0999755859, 27.45),
			},
			size = vector3(3, 3, 4), -- size of the vehicles zones (x, y, z)
			targetDistance = 1, -- Defines targeting distance. Only works if targeting is enabled
			debug = false
		},
		Job = 'none', -- Name of job or none
		ShopLabel = 'Premium Deluxe Motorsport', -- Blip name
		showBlip = true, -- true or false
		blipSprite = 326, -- Blip sprite
		blipColor = 3, -- Blip color
		Categories = {
			-- Categories available to browse
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
		TestDriveTimeLimit = 0.5, -- Time in minutes until the vehicle gets deleted
		TestDriveReturnLocation = vector4(-33.35, -1110.81, 27.26, 164.41), -- Return position once test drive is finished. Set to front of the shop by default
		Location = vector3(-45.67, -1098.34, 26.42), -- Blip Location
		ReturnLocation = vector3(-16.64, -1079.87, 26.56), -- Location to return vehicle, only enables if the vehicleshop has a job owned
		VehicleSpawn = vector4(-23.6, -1094.4, 27.0, 340.0), -- Spawn location when vehicle is bought
		TestDriveSpawn = vector4(-7.24, -1084.81, 26.87, 114.26), -- Spawn location for test drive
		ShowroomVehicles = {
			[1] = {
				coords = vector4(-37.05, -1093.3, 26.0, 69.5), -- where the vehicle will spawn on display
				defaultVehicle = 'blista', -- Default display vehicle
				chosenVehicle = 'blista', -- Same as default but is dynamically changed when swapping vehicles
			},
			[2] = {
				coords = vector4(-42.35, -1101.35, 26.0, 294.5),
				defaultVehicle = 'schafter2',
				chosenVehicle = 'schafter2'
			},
			[3] = {
				coords = vector4(-47.5, -1092.0, 26.0, 66.5),
				defaultVehicle = 'comet2',
				chosenVehicle = 'comet2'
			},
			[4] = {
				coords = vector4(-54.65, -1096.85, 26.0, 254.5),
				defaultVehicle = 'vigero',
				chosenVehicle = 'vigero'
			},
			[5] = {
				coords = vector4(-49.9, -1083.75, 26.0, 165.0),
				defaultVehicle = 'intruder',
				chosenVehicle = 'intruder'
			},
		},
	},
	luxury = {
		Type = 'managed', -- meaning a real player has to sell the car
		Zone = {
			Shape = {
				vector3(-1260.6973876953, -349.21334838867, 36.91),
				vector3(-1268.6248779297, -352.87365722656, 36.91),
				vector3(-1274.1533203125, -358.29794311523, 36.91),
				vector3(-1273.8425292969, -362.73715209961, 36.91),
				vector3(-1270.5701904297, -368.6716003418, 36.91),
				vector3(-1266.0561523438, -375.14080810547, 36.91),
				vector3(-1244.3684082031, -362.70278930664, 36.91),
				vector3(-1249.8704833984, -352.03326416016, 36.91),
				vector3(-1252.9503173828, -345.85726928711, 36.91)
			},
			size = vector3(3, 3, 4), -- size of the vehicles zones (x, y, z)
			targetDistance = 1, -- Defines targeting distance. Only works if targeting is enabled
			debug = false
		},
		Job = 'cardealer', -- Name of job or none
		ShopLabel = 'Luxury Vehicle Shop',
		showBlip = true, -- true or false
		blipSprite = 326, -- Blip sprite
		blipColor = 3, -- Blip color
		Categories = {
			super = 'Super',
			sports = 'Sports'
		},
		TestDriveTimeLimit = 0.5,
		TestDriveReturnLocation = vector4(-1261.56, -347.54, 36.83, 216.22), -- Return position once test drive is finished. Set to front of the shop by default
		Location = vector3(-1255.6, -361.16, 36.91),
		ReturnLocation = vector3(-1231.46, -349.86, 37.33),
		VehicleSpawn = vector4(-1231.46, -349.86, 37.33, 26.61),
		TestDriveSpawn = vector4(-1232.81, -347.99, 37.33, 23.28), -- Spawn location for test drive
		ShowroomVehicles = {
			[1] = {
				coords = vector4(-1265.31, -354.44, 35.91, 205.08),
				defaultVehicle = 'italirsx',
				chosenVehicle = 'italirsx'
			},
			[2] = {
				coords = vector4(-1270.06, -358.55, 35.91, 247.08),
				defaultVehicle = 'italigtb',
				chosenVehicle = 'italigtb'
			},
			[3] = {
				coords = vector4(-1269.21, -365.03, 35.91, 297.12),
				defaultVehicle = 'nero',
				chosenVehicle = 'nero'
			},
			[4] = {
				coords = vector4(-1252.07, -364.2, 35.91, 56.44),
				defaultVehicle = 'bati',
				chosenVehicle = 'bati'
			},
			[5] = {
				coords = vector4(-1255.49, -365.91, 35.91, 55.63),
				defaultVehicle = 'carbonrs',
				chosenVehicle = 'carbonrs'
			},
			[6] = {
				coords = vector4(-1249.21, -362.97, 35.91, 53.24),
				defaultVehicle = 'hexer',
				chosenVehicle = 'hexer'
			},
		}
	}, -- Add your next table under this comma
	boats = {
		Type = 'free-use', -- no player interaction is required to purchase a vehicle
		Zone = {
			Shape = {
				--polygon that surrounds the shop
				vector3(-729.39, -1315.84, 0),
				vector3(-766.81, -1360.11, 0),
				vector3(-754.21, -1371.49, 0),
				vector3(-716.94, -1326.88, 0)
			},
			size = vector3(8, 8, 6), -- size of the vehicles zones (x, y, z)
			targetDistance = 5, -- Defines targeting distance. Only works if targeting is enabled
			debug = false
		},
		Job = 'none', -- Name of job or none
		ShopLabel = 'Marina Shop', -- Blip name
		showBlip = true, -- true or false
		blipSprite = 410, -- Blip sprite
		blipColor = 3, -- Blip color
		Categories = {
			-- Categories available to browse
			boats = 'Boats'
		},
		TestDriveTimeLimit = 1.5, -- Time in minutes until the vehicle gets deleted
		TestDriveReturnLocation = vector4(-733.19, -1313.45, 5.0, 226.37), -- Return position once test drive is finished. Set to front of the shop by default
		Location = vector3(-738.25, -1334.38, 1.6), -- Blip Location
		ReturnLocation = vector3(-714.34, -1343.31, 0.0), -- Location to return vehicle, only enables if the vehicleshop has a job owned
		VehicleSpawn = vector4(-727.87, -1353.1, -0.17, 137.09), -- Spawn location when vehicle is bought
		TestDriveSpawn = vector4(-722.23, -1351.98, 0.14, 135.33), -- Spawn location for test drive
		ShowroomVehicles = {
			[1] = {
				coords = vector4(-727.05, -1326.59, -0.50, 229.5), -- where the vehicle will spawn on display
				defaultVehicle = 'seashark', -- Default display vehicle
				chosenVehicle = 'seashark' -- Same as default but is dynamically changed when swapping vehicles
			},
			[2] = {
				coords = vector4(-732.84, -1333.5, -0.50, 229.5),
				defaultVehicle = 'dinghy',
				chosenVehicle = 'dinghy'
			},
			[3] = {
				coords = vector4(-737.84, -1340.83, -0.50, 229.5),
				defaultVehicle = 'speeder',
				chosenVehicle = 'speeder'
			},
			[4] = {
				coords = vector4(-741.53, -1349.7, -0.50, 229.5),
				defaultVehicle = 'marquis',
				chosenVehicle = 'marquis'
			},
		},
	},
	air = {
		Type = 'free-use', -- no player interaction is required to purchase a vehicle
		Zone = {
			Shape = {
				--polygon that surrounds the shop
				vector3(-1607.58, -3141.7, 12.99),
				vector3(-1672.54, -3103.87, 12.99),
				vector3(-1703.49, -3158.02, 12.99),
				vector3(-1646.03, -3190.84, 12.99)
			},
			size = vector3(10, 10, 8), -- size of the vehicles zones (x, y, z)
			targetDistance = 5, -- Defines targeting distance. Only works if targeting is enabled
			debug = false
		},
		Job = 'none', -- Name of job or none
		ShopLabel = 'Air Shop', -- Blip name
		showBlip = true, -- true or false
		blipSprite = 251, -- Blip sprite
		blipColor = 3, -- Blip color
		Categories = {
			-- Categories available to browse
			helicopters = 'Helicopters',
			planes = 'Planes'
		},
		TestDriveTimeLimit = 1.5, -- Time in minutes until the vehicle gets deleted
		TestDriveReturnLocation = vector4(-1639.39, -3120.24, 13.94, 148.31), -- Return position once test drive is finished. Set to front of the shop by default
		Location = vector3(-1652.76, -3143.4, 13.99), -- Blip Location
		ReturnLocation = vector3(-1628.44, -3104.7, 13.94), -- Location to return vehicle, only enables if the vehicleshop has a job owned
		VehicleSpawn = vector4(-1617.49, -3086.17, 13.94, 329.2), -- Spawn location when vehicle is bought
		TestDriveSpawn = vector4(-1625.19, -3103.47, 13.94, 330.28), -- Spawn location for test drive
		ShowroomVehicles = {
			[1] = {
				coords = vector4(-1651.36, -3162.66, 12.99, 346.89), -- where the vehicle will spawn on display
				defaultVehicle = 'volatus', -- Default display vehicle
				chosenVehicle = 'volatus' -- Same as default but is dynamically changed when swapping vehicles
			},
			[2] = {
				coords = vector4(-1668.53, -3152.56, 12.99, 303.22),
				defaultVehicle = 'luxor2',
				chosenVehicle = 'luxor2'
			},
			[3] = {
				coords = vector4(-1632.02, -3144.48, 12.99, 31.08),
				defaultVehicle = 'nimbus',
				chosenVehicle = 'nimbus'
			},
			[4] = {
				coords = vector4(-1663.74, -3126.32, 12.99, 275.03),
				defaultVehicle = 'frogger',
				chosenVehicle = 'frogger'
			},
		},
	},
}
Config.Vehicles = {
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
		shop = 'pdm', 							--DLC
	},
	issi5 = {
		shop = 'pdm',							--DLC
	},
	issi6 = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm', 			--DLC +set sv_enforceGameBuild 2372
	},
	champion = {
		shop = 'pdm', 		--DLC +set sv_enforceGameBuild 2545
	},
	ignus = {
		shop = 'pdm',		--DLC +set sv_enforceGameBuild 2545
	},
	zeno = {
		shop = 'pdm',		--DLC +set sv_enforceGameBuild 2545
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
		shop = 'pdm',							--DLC
	},
	deathbike2 = {
		shop = 'pdm',							--DLC
	},
	deathbike3 = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',		--DLC +set sv_enforceGameBuild 2545
	},
	reever = {
		shop = 'pdm',		--DLC +set sv_enforceGameBuild 2545
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
		shop = 'pdm',							--DLC
	},
	coquette3 = {
		shop = 'pdm',
	},
	deviant = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
	},
	dominator7 = {
		shop = 'pdm',							--DLC +set sv_enforceGameBuild 2372
	},
	dominator8 = {
		shop = 'pdm',							--DLC +set sv_enforceGameBuild 2372
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
		shop = 'pdm',							--DLC
	},
	gauntlet4 = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
	},
	impaler2 = {
		shop = 'pdm',							--DLC
	},
	impaler3 = {
		shop = 'pdm',							--DLC
	},
	impaler4 = {
		shop = 'pdm',							--DLC
	},
	imperator = {
		shop = 'pdm',							--DLC
	},
	imperator2 = {
		shop = 'pdm',							--DLC
	},
	imperator3 = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
	},
	vamos = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
	},
	hellion = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
	},
	xls = {
		shop = 'pdm',
	},
	granger2 = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC +set sv_enforceGameBuild 2372
	},
	cinquemila = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	iwagen = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	astron = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	baller7 = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	comet7 = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	deity = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	jubilee = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	patriot3 = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
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
		shop = 'luxury',							--DLC
	},
	deveste = {
		shop = 'luxury',							--DLC
	},
	elegy = {
		shop = 'luxury',							--DLC
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
		shop = 'pdm',							--DLC
	},
	italigto = {
		shop = 'luxury',							--DLC
	},
	jugular = {
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
	},
	neon = {
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	calico = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	futo2 = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	euros = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	jester4 = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	remus = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	comet6 = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	growler = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	vectre = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	cypher = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
	},
	sultan3 = {
	},
	rt3000 = {
		shop = 'luxury',							--DLC +set sv_enforceGameBuild 2372
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
		shop = 'pdm',							--DLC
	},
	fagaloa = {
		shop = 'pdm',
	},
	feltzer3 = {
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
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
		shop = 'pdm',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
	},
	sc1 = {
		shop = 'luxury',
	},
	sheava = {
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
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
		shop = 'luxury',							--DLC
	},
	-- Vans
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
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	mule5 = {
		shop = 'pdm', 	 	--DLC +set sv_enforceGameBuild 2545
	},
	-- Utility
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
		shop = 'pdm',							--DLC +set sv_enforceGameBuild 2372
	},
	-- Boats
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
	-- helicopters
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
	-- Planes
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
		shop = 'pdm',          --DLC +set sv_enforceGameBuild 2699 (and below)
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
}
