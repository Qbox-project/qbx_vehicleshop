fx_version 'cerulean'
game 'gta5'

description 'Vehicleshop for Qbox'
repository 'https://github.com/Qbox-project/qbx_vehicleshop'
version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/storage.lua',
}

files {
    'config/client.lua',
    'config/shared.lua',
}

provide 'qb-vehicleshop'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
