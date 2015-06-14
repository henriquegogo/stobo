#!./bin/lua

require 'stobo'

local lgi = require 'lgi'
local Gtk = lgi.Gtk

local builder = Gtk.Builder()
builder:add_from_file('app/screen.glade')

local window         = builder:get_object('main')
local statusbar      = builder:get_object('statusbar')
local listYears      = builder:get_object('listYears')
local listStocks     = builder:get_object('listStocks')
local stocksCombo    = builder:get_object('stocks')
local yearsCombo     = builder:get_object('years')
local startDateEntry = builder:get_object('startDate')
local endDateEntry   = builder:get_object('endDate')
local textview       = builder:get_object('textview')
local textbuffer     = builder:get_object('textbuffer')

local stockList = {}
local filtredStockList = {}

-- Fill years combo
local years = { '2015', '2014', '2013', '2012', '2011' }
for i,year in pairs(years) do
  listYears:append({ year })
end

function status(text)
  print(text)
  statusbar:push(0, text)
  while Gtk.events_pending() do
    Gtk.main_iteration()
  end
end

function fillStocksCombo()
  listStocks:clear()

  status('Montando exibição de ações...')
  listStocks:append({ '' })
  for i,symbol in pairs(filtredStockList:symbols()) do
    listStocks:append({ symbol })
  end
end

print 'Bidding screen signals'
builder:connect_signals {
  on_year_changed = function()
    startDateEntry:set_text('')
    endDateEntry:set_text('')

    local selectedYearIndex = yearsCombo:get_active() + 1
    local selecterYear = years[selectedYearIndex]

    status('Obtendo dados...')
    local dataText = Database.get('05'..selecterYear)

    status('Processando banco de dados...')
    stockList = Stocks.new(dataText)
    filtredStockList = stockList
        
    fillStocksCombo()

    status('Pronto')
  end,

  on_startDate_changed = function()
    local startDateValue = startDateEntry:get_text() 
    local endDateValue = endDateEntry:get_text() 
    local selectedStockValue = stockList:symbols()[stocksCombo:get_active() + 1]

    filtredStockList = stockList:bySymbol(selectedStockValue)
                                :byStartDate(startDateValue)
                                :byEndDate(endDateValue)

    local output = inspect(filtredStockList)
    textbuffer:set_text(output, #output)
  end,

  on_endDate_changed = function()
    local startDateValue = startDateEntry:get_text() 
    local endDateValue = endDateEntry:get_text() 
    local selectedStockValue = stockList:symbols()[stocksCombo:get_active() + 1]
    
    filtredStockList = stockList:bySymbol(selectedStockValue)
                                :byStartDate(startDateValue)
                                :byEndDate(endDateValue)

    local output = inspect(filtredStockList)
    textbuffer:set_text(output, #output)
  end,

  on_stocks_changed = function()
    local startDateValue = startDateEntry:get_text() 
    local endDateValue = endDateEntry:get_text() 
    local selectedStockValue = stockList:symbols()[stocksCombo:get_active() + 1]

    filtredStockList = stockList:bySymbol(selectedStockValue)
                                :byStartDate(startDateValue)
                                :byEndDate(endDateValue)

    local output = inspect(filtredStockList)
    textbuffer:set_text(output, #output)
  end
}

window.on_destroy = Gtk.main_quit
window:show_all()
Gtk.main()
