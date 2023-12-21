local Translations = {
    error = {
        testdrive_alreadyin = "Már próbaút alatt van",
        testdrive_return = "Ez nem a te próbajárműved",
        Invalid_ID = "Érvénytelen Játékos ID",
        playertoofar = "A játékos nincs elég közel hozzád",
        notenoughmoney = "Nincs elegendő pénzed",
        minimumallowed = "Minimum befizetés $", --Minimum payment allowed is $ hogy a kurva anyámba mondod ezt magyarul geci
        overpaid = "Túlfizettél",
        alreadypaid = "A jármű már kivan fizetve",
        notworth = "Nem ér annyit a jármű",
        downtoosmall = "Az előleg összege túl kicsi",
        exceededmax = "Túl lépte a maximális kifizetési összeget", -- hibás
        repossessed = "A te %{plate} rendszámú járműved visszafoglalásra került",
        buyerinfo = "Nem sikerült megszerezni a vásárló adatait",
        notinveh = "Eladáshoz a járműben kell tartózkodnod",
        vehinfo = "A jármű információk nem elérhetőek",
        notown = "Ez a jármű nem a te birtokodban áll",
        buyertoopoor = "A vásárlónak nem áll rendelkezésre elegendő fizető eszköze",
        nofinanced = "Nincsen hitelezett járműved",
        financed = "Ez a jármű hitelezett",
        buyerdeclined = "The player declined the transaction",
    },
    success = {
        purchased = "Gratulálunk a vásárláshoz!",
        earned_commission = "$ %{amount} jutalékot kerestél",
        gifted = "Elajándékoztad a járműved",
        received_gift = "Ajándékba kaptál egy járművet",
        soldfor = "Eladtad a járműved $",
        boughtfor = "Vásároltál egy járművet $",
    },
    menus = {
        vehHeader_header = "Jármű lehetőségek",
        vehHeader_txt = "Interakció a jelenlegi járművel",
        financed_header = "Hitelezett járművek",
        finance_txt = "Keresés a saját járművek között",
        returnTestDrive_header = "Teszt vezetés befejezése",
        categories_header = "Kategoriák",
        goback_header = "Visszalépés",
        veh_price = "Ár: $",
        veh_platetxt = "Rendszám: ",
        veh_finance = "Jármű fizetés",
        veh_finance_balance = "Fennálló egyenleg",
        veh_finance_currency = "$",
        veh_finance_total = "Fennálló kifizetés",
        veh_finance_reccuring = "Fizetendő részlet",
        veh_finance_pay = "Fizetés",
        veh_finance_payoff = "Jármű kifizetése",
        veh_finance_payment = "Fizetendő összeg ($)",
        submit_text = "Küldés",
        test_header = "Teszt vezetés",
        finance_header = "Jármű hitelezése",
        owned_vehicles_header = "Birtokolt járművek",
        swap_header = "Jármű csere",
        swap_txt = "Az aktuálisan kiválaszott jármű cseréje",
        financesubmit_downpayment = "Az előleg legalább - Min ",
        financesubmit_totalpayment = "Teljes kifizetés - Max ",
        --Free Use
        freeuse_test_txt = "Jelenlegi jármű teszt vezetése",
        freeuse_buy_header = "Jármű megvásárlása",
        freeuse_buy_txt = "Kiválaszott jármű megvétele",
        freeuse_finance_txt = "Kiválaszott jármű hitelezése",
        --Managed
        managed_test_txt = "Vásárló tesztvezetésének engedélyezése",
        managed_sell_header = "Jármű eladás",
        managed_sell_txt = "Kiválaszott jármű eladása",
        managed_finance_txt = "Kiválaszott jármű hitelezése a vásárlónak",
        submit_ID = "Idéglenes aktív személyiszám (#)",
        keypress_showFinanceMenu = "[E] Hitelezési menü megnyitása",
        --Floating
        keypress_vehicleViewMenu = "[E] Jármű megnézése"
    },
    general = {
        testdrive_timer = "Teszt vezetésből hátramaradt idő:",
        vehinteraction = "Jármű interakció",
        testdrive_timenoti = "%{testdrivetime} másodperced van még hátra",
        testdrive_complete = "Tesztvezetés befejezése",
        paymentduein = "A jármű törlesztőrészletének kifizetéséig %{time} perc van hátra",
        command_transfervehicle = "Jármű eladása vagy elajándékozása",
        command_transfervehicle_help = "Vásárló idéglenes aktív személyiszáma (ID)",
        command_transfervehicle_amount = "Eladási ár (opcionális)",
    }
}

if GetConvar('qb_locale', 'en') == 'hu' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end