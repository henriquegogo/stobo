#!./bin/lua

local lgi = require 'lgi'
local Gtk = lgi.Gtk

local builder = Gtk.Builder()
builder:add_from_file('app/screen.glade')

local listStocks = builder:get_object('listStocks')
listStocks:append({ 'PETR4' })
listStocks:append({ 'ABEV3' })

local stocksCombo = builder:get_object('stocks')
stocksCombo:set_active(0)

builder:connect_signals {
   buttonClick = function()
     print('Button Click')
   end
}

local window = builder:get_object('main')
window.on_destroy = Gtk.main_quit
window:show_all()

Gtk.main()
