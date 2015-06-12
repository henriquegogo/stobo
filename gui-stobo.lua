#!./bin/lua

require 'stobo'

local lgi = require 'lgi'
local Gtk = lgi.Gtk

local data_text = Database.get('05052015')
local stockList = Stocks.new(data_text)

local builder = Gtk.Builder()
builder:add_from_file('app/screen.glade')

local listStocks = builder:get_object('listStocks')

for i,symbol in pairs(stockList:symbols()) do
  listStocks:append({ symbol })
end

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
