fx_version 'adamant'
game 'gta5'
version '1.0.0'
author 'Garage'

server_scripts {
  '@async/async.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  'client/main.lua',
  'config.lua'
}

shared_scripts {
  '@es_extended/imports.lua',
}

ui_page 'html/index.html'
files {
  'html/index.html',
  'html/style.css', 
  'html/script.js'
}