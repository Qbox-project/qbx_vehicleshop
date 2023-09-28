fx_version 'cerulean'
game 'gta5'

description 'Vehicleshop for Qbox'
repository 'https://github.com/Qbox-project/qbx_vehicleshop'
version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    '@qbx_core/shared/locale.lua',
    '@qbx_core/import.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/storage.lua',
}


modules {
    'qbx_core:playerdata',
    'qbx_core:utils'
}

provide 'qb-vehicleshop'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
