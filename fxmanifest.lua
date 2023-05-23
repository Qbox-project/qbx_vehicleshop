fx_version 'cerulean'
game 'gta5'

description 'qb-vehicleshop'
version '1.0.0'

shared_script {
    'config.lua',
    '@ox_lib/init.lua',
    'locales/*.json'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

lua54 'yes'
