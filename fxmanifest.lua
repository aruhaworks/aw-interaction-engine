fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ARUHAWORKS'
description 'High-performance server-authoritative FiveM interaction engine'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/spatial_hash.lua'
}

client_scripts {
    'client/interaction.lua'
}

server_scripts {
    'server/interaction.lua',
    'server/example.lua'
}

exports {
    'AddInteraction',
    'RemoveInteraction',
    'GetInteraction'
}
