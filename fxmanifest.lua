fx_version 'cerulean'
game 'gta5'

description 'https://github.com/Qbox-project/qbx-vehicleshop'
version '1.0.0'

shared_script {
    'config.lua',
    '@qbx-core/shared/locale.lua',
    '@qbx-core/import.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'storage.lua',
}

files {
    'client/utils.lua'
}

modules {
    'qbx-core:core',
    'qbx-core:playerdata',
    'qbx-core:utils'
}

provide 'qb-vehicleshop'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
