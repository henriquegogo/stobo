#!./bin/lua

require 'stobo'
local colors = require 'ansicolors'

local dataText = Database.get('2014')
local stockList = Stocks.new(dataText)

local petrobras = stockList:bySymbol('PETR4')
local sma20 = petrobras:SMA(20)

print("DATE      PRICE    \tSMA")
for i,quote in ipairs(petrobras.quotes) do
  local lastQuote = petrobras.quotes[i-1]
  local signal = ''
  local sma = sma20[i]
  local lastSma = sma20[i-1]
  local smaSignal = ''

  if lastQuote then
    local quotesDiff = quote.close - lastQuote.close
    local smaDiff = sma - lastSma

    signal = (quotesDiff > 0) and colors('%{green}+') or colors('%{red}-')
    smaSignal = (smaDiff > 0) and colors('%{green}+') or colors('%{red}-')
  end

  local output = string.format("%s: %s%s  \t%s%s", quote.date, signal, quote.close, smaSignal, sma)
  print(output)
end
