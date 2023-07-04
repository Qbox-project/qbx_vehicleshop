fx_version 'cerulean'
game 'gta5'

description 'qb-vehicleshop'
version '1.0.0'

shared_script {
    'config.lua',
    '@qbx-core/shared/locale.lua',
    '@qbx-core/import.lua',
    '@ox_lib/init.lua',
    'locales/en.lua' -- Change this to your preferred language
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'storage.lua',
}

files {
    'client/utils.lua'
}

modules {
    'qbx-core:utils'
}

provide 'qb-vehicleshop'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
