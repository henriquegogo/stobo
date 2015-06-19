#!./bin/lua

require 'stobo'

local dataText = Database.get('2015')
local stockList = Stocks.new(dataText)

local petrobras = stockList:bySymbol('PETR4')

for i,quote in ipairs(petrobras.quotes) do
  local lastQuote = petrobras.quotes[i-1]
  local signal = ''

  if lastQuote then
    local quoteMinusLast = quote.close - lastQuote.close
    signal = (quoteMinusLast > 0) and '  >' or '<  '
  end

  io.write(quote.date..': '..quote.close..' ')
  io.write(signal)
  io.write('\n')
end
