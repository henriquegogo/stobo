#!./bin/lua

require 'stobo'

local lgi = require 'lgi'
local Gtk = lgi.Gtk

local builder = Gtk.Builder()
builder:add_from_file('app/screen.glade')

local window      = builder:get_object('main')
local statusbar   = builder:get_object('statusbar')
local listYears   = builder:get_object('listYears')
local listStocks  = builder:get_object('listStocks')
local stocksCombo = builder:get_object('stocks')
local stocksCombo = builder:get_object('stocks')
local startDate   = builder:get_object('startDate')

function status(text)
  print(text)
  statusbar:push(0, text)
  while Gtk.events_pending() do
    Gtk.main_iteration()
  end
end

print 'Bidding screen signals'
builder:connect_signals {
  year_changed_cb = function(widget)
    local selectedYearIndex = widget:get_active()
    local selectedYear = listYears

    status('Obtendo dados...')
    local dataText = Database.get('052015')

    status('Processando banco de dados...')
    local stockList = Stocks.new(dataText)
        
    status('Montando exibição de ações...')
    for i,symbol in pairs(stockList:symbols()) do
      listStocks:append({ symbol })
    end

    status('Pronto')
  end,

  stocks_changed_cb = function(widget)
  end
}

window.on_destroy = Gtk.main_quit
window:show_all()
Gtk.main()
