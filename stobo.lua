#!./bin/lua

-- Load libraries
local inspect = require 'inspect'
local http = require 'socket.http'
local zip = require 'zip'

-- Load project files
require 'app.database'
require 'app.quote'
require 'app.stocks'

-- Main
do
  local data_text = Database.get('052015')
  local stockList = Stocks.new(data_text)
  print 'Done'

  print 'All ABEV3 from date 20150605'
  print(inspect( stockList:bySymbol('ABEV3') ))

  print 'All PETR4 from date 20150605'
  print(inspect( stockList:byDate('20150505'):bySymbol('PETR4') ))

  print 'All from date 20150301 to date 20150504'
  print(inspect( stockList:byStartDate('20150301')
                          :byEndDate('20150504')
                          :byCriteria(function(quote)
                            local high = tonumber(quote.high)
                            return high > 80 and high < 90
                          end)))

  print('SMA: '.. inspect( stockList:bySymbol('LAME3'):SMA(3) ))

  local lame3 = stockList:bySymbol('LAME3')
  print('LAME3 length: '..#lame3.quotes)
  print('LAME3 SMA length: '..#lame3:SMA(3))
end
