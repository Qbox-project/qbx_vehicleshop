fx_version 'cerulean'
game 'gta5'

description 'qb-vehicleshop'
version '2.0.0'

shared_script {
    'config.lua',
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua' -- Change this to your preferred language
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'
