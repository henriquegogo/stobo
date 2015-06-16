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
local byVolumeCheck  = builder:get_object('byVolume')

local stockList = {}
local filtredStockList = {}
local symbols = {}

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
  local listByVolume = byVolumeCheck:get_active()
  symbols = filtredStockList:symbols(listByVolume)

  listStocks:clear()
  
  status('Montando exibição de ações...')
  for i,symbol in ipairs(symbols) do
    listStocks:append({ symbol })
  end
end

function displayOutput()
  local selecterYear = years[yearsCombo:get_active() + 1]
  local startDateValue = startDateEntry:get_text()
  local endDateValue = endDateEntry:get_text() 
  local selectedStockValue = symbols[stocksCombo:get_active() + 1]

  local startDateWithYear = #startDateValue == 4 and selecterYear..startDateValue or ''
  local endDateWithYear = #endDateValue == 4 and selecterYear..endDateValue or ''

  filtredStockList = stockList:bySymbol(selectedStockValue)
                              :byStartDate(startDateWithYear)
                              :byEndDate(endDateWithYear)

  local outputText = ''
  for i,quote in ipairs(filtredStockList.quotes) do
    outputText = outputText..quote.symbol..
                 ' ('..quote.date..') -'..
                 ' O:'..quote.open..
                 ' H:'..quote.high..
                 ' L:'..quote.low..
                 ' C:'..quote.close..
                 ' V:'..quote.volume..
                 '\n'
  end

  textbuffer:set_text(outputText, #outputText)
end

print 'Bidding screen signals'
builder:connect_signals {
  on_year_changed = function()
    startDateEntry:set_text('')
    endDateEntry:set_text('')

    local selecterYear = years[yearsCombo:get_active() + 1]

    status('Obtendo dados...')
    local dataText = Database.get('05'..selecterYear)

    status('Processando banco de dados...')
    stockList = Stocks.new(dataText)
    filtredStockList = stockList -- TODO: Identificar bug de selecionar ano novamente
    status('Exibindo stocks no combo...')
    fillStocksCombo()

    status('Pronto')
  end,

  on_startDate_changed = function(widget)
    local textValue = widget:get_text() 
    if #textValue == 4 then displayOutput() end
  end,

  on_endDate_changed = function(widget)
    local textValue = widget:get_text() 
    if #textValue == 4 then displayOutput() end
  end,

  on_stocks_changed = function()
    displayOutput()
  end,

  on_byVolume_toggled = function()
    fillStocksCombo()
  end
}

window.on_destroy = Gtk.main_quit
window:show_all()
Gtk.main()
