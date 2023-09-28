# qbx_vehicleshop

**Test Drives:**
* Configurable time
* Returns player once time is up
* Can't take out more than one vehicle

**Financing:**
* Configurable down payment
* Configurable maximum payments
* Configurable commission amount for private dealerships
* Checks for payments due on player join and updates times on player logout or quit

**Shops:**
* Lock to a specific job
* Commission paid to sales person for private dealer
* Create as many as desired with easy polyzone creation
* Vehicle sale amount gets deposited into the cardealer society fund for private dealer

**Planned Updates**
* qbx_phone support to make payments

**Preview header when near a vehicle at the public dealership:**

![image](https://user-images.githubusercontent.com/57848836/138773379-836be2a6-a800-47a4-8037-84d9052a964c.png)

**After pressing the focus key and selecting the preview header (default: LEFT ALT)**

![image](https://user-images.githubusercontent.com/57848836/138770886-15e056db-3e57-43ea-b855-3ef4fd107acf.png)

**Configurable test drive times that automatically return the player**
![20211025160757_1](https://user-images.githubusercontent.com/57848836/138771162-00ee2607-0b56-418b-848c-5d8a009f4acd.jpg)

**Vehicle purchasing**
![20211025160853_1](https://user-images.githubusercontent.com/57848836/138772385-ce16c0e6-baea-4b54-8eff-dbf44c54f568.jpg)

**Private job-based dealership menu (works off closest player)**

![image](https://user-images.githubusercontent.com/57848836/138772120-9513fa09-a22f-4a5f-8afe-6dc7756999f4.png)

**Financing a vehicle with configurable max payment amount and minimum downpayment percentage**
![image](https://user-images.githubusercontent.com/57848836/138771328-0b88078c-9f3d-4754-a4c7-bd5b68dd5129.png)

**Financing preview header**

![image](https://user-images.githubusercontent.com/57848836/138773600-d6f510f8-a476-436d-8211-21e8c920eb6b.png)

**Finance vehicle list**

![image](https://user-images.githubusercontent.com/57848836/138771582-727e7fd4-4837-4320-b79a-479a6268b7ac.png)

**Make a payment or pay off vehicle in full**

![image](https://user-images.githubusercontent.com/57848836/138771627-faed7fcb-73c8-4b77-a33f-fffbb738ab03.png)

### Dependencies:

**[PolyZone](https://github.com/qbcore-framework/PolyZone)**

* You need to create new PolyZones if you want to create a new dealership or move default locations to another area. After you create the new PolyZones, add them to the Config.Shops > [Shape]

* Here's a Wiki on how to create new PolyZone:
https://github.com/mkafrin/PolyZone/wiki/Using-the-creation-script

```lua
Config = {}
Config.UsingTarget = GetConvar('UseTarget', 'false') == 'true'
Config.Commission = 0.10 -- Percent that goes to sales person from a full car sale 10%
Config.EnableFinance = true -- allows financing new vehicles. Turning off does not affect already financed vehicles
Config.EnableFreeUseBuy = true -- allows players to buy from NPC shops
Config.FinanceCommission = 0.05 -- Percent that goes to sales person from a finance sale 5%
Config.FinanceZone = vector3(-29.53, -1103.67, 26.42)-- Where the finance menu is located
Config.PaymentWarning = 10 -- time in minutes that player has to make payment before repo
Config.PaymentInterval = 24 -- time in hours between payment being due
Config.MinimumDown = 10 -- minimum percentage allowed down
Config.MaximumPayments = 24 -- maximum payments allowed
Config.PreventFinanceSelling = false -- allow/prevent players from using /transfervehicle if financed
Config.Shops = {
    pdm = {
        Type = 'free-use', -- no player interaction is required to purchase a car
        Zone = {
            Shape = {--polygon that surrounds the shop
                vector3(-56.727394104004, -1086.2325439453, 26.0),
                vector3(-60.612808227539, -1096.7795410156, 26.0),
                vector3(-58.26834487915, -1100.572265625, 26.0),
                vector3(-35.927803039551, -1109.0034179688, 26.0),
                vector3(-34.427627563477, -1108.5111083984, 26.0),
                vector3(-32.02657699585, -1101.5877685547, 26.0),
                vector3(-33.342102050781, -1101.0377197266, 26.0),
                vector3(-31.292987823486, -1095.3717041016, 26.0)
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
        Categories = {-- Categories available to browse
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
        TestDriveReturnLocation = vector4(-24.84, -1086.55, 26.57, 70.5), -- Return position once test drive is finished
        Location = vector3(-45.67, -1098.34, 26.42), -- Blip Location
        ReturnLocation = vector3(-44.74, -1082.58, 26.68), -- Location to return vehicle, only enables if the vehicleshop has a job owned
        VehicleSpawn = vector4(-31.69, -1090.78, 26.42, 328.79), -- Spawn location when vehicle is bought
        TestDriveSpawn = vector4(-7.84, -1081.35, 26.67, 121.83), -- Spawn location for test drive
        ShowroomVehicles = {
            [1] = {
                coords = vector4(-45.65, -1093.66, 25.44, 69.5), -- where the vehicle will spawn on display
                defaultVehicle = 'adder', -- Default display vehicle
                chosenVehicle = 'adder', -- Same as default but is dynamically changed when swapping vehicles
            },
            [2] = {
                coords = vector4(-48.27, -1101.86, 25.44, 294.5),
                defaultVehicle = 'schafter2',
                chosenVehicle = 'schafter2'
            },
            [3] = {
                coords = vector4(-39.6, -1096.01, 25.44, 66.5),
                defaultVehicle = 'comet2',
                chosenVehicle = 'comet2'
            },
            [4] = {
                coords = vector4(-51.21, -1096.77, 25.44, 254.5),
                defaultVehicle = 'vigero',
                chosenVehicle = 'vigero'
            },
            [5] = {
                coords = vector4(-40.18, -1104.13, 25.44, 338.5),
                defaultVehicle = 't20',
                chosenVehicle = 't20'
            },
            [6] = {
                coords = vector4(-43.31, -1099.02, 25.44, 52.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            },
            [7] = {
                coords = vector4(-50.66, -1093.05, 25.44, 222.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            },
            [8] = {
                coords = vector4(-44.28, -1102.47, 25.44, 298.5),
                defaultVehicle = 'bati',
                chosenVehicle = 'bati'
            }
        },
    }
```

# License notice
Due to unfortunate events, we had to remove the commit history of this repository. closed-source code was introduced of which the original copyright holder hadn't given anyone permission to share and was illegally obtained. This doesn't mean that the original contributors lost their copyright rights and still are copyright holders. This includes but is not limited to.
- legende11 | masonschafercodes | GhzGarage | Newtonzz | TheiLLeniumStudios | IdrisDose | r0adra93 | uShifty | Holidayy95 | erikmeyer08 | OlliePugh | roobr | gutsoo | Re1ease | TonybynMp4 | mjvanhaastert | Dwohakin | trclassic92 | ARSSANTO | TheiLLeniumStudios | BerkieBb | adweex | DannysRP | mNm-server | arsh939 | AbrahamMoody | buddizer | Z3rio | wanderrer | vosscat | LouieBandz514 | NoobySloth | merpindia | Belorico | Dhawgy | Sna-aaa | Brusein | PlanovskyJus | CptAllen | Evantually | amantu-qbit | MonkeyWhisper | Mobius1 | Demo4889 | DanteRedrum | steveski | DOSE-420 | nzkfc | izMystic | Aveeux
