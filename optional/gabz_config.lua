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
