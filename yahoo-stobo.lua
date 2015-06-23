#!./bin/lua

local inspect = require 'inspect'
local http = require 'socket.http'
local https = require 'ssl.https'
local cjson = require 'cjson'

local api_url = 'https://finance-yql.media.yahoo.com/v7/finance/chart/%s?period1=%s&period2=%s&interval=%s'

-- Quote
Quote = {} do
  local numberOrNil = function(number)
    if type(number) == 'number' then
      return number
    else
      return 0
    end
  end
  
  local floatToInt = function(number)
    if type(number) == 'number' then
      return math.floor(number)
    end
  end

  function Quote.new(timestamp, open, low, high, close, volume)
    local self = setmetatable({}, { __index = Quote })

    local datetable = os.date('*t', timestamp)

    self.datetime = ('%04d%02d%02d%02d%02d'):format(datetable.year,
                    datetable.month, datetable.day,
                    datetable.hour, datetable.min)
    
    self.open = numberOrNil(open)
    self.low = numberOrNil(low)
    self.high = numberOrNil(high)
    self.close = numberOrNil(close)
    self.volume = floatToInt(numberOrNil(volume))
    
    return self
  end
end

-- Stock
Stock = {} do
  function Stock.new(symbol)
    local self = setmetatable({}, { __index = Stock })
    
    self.symbol = symbol
    self.quotes = {}

    return self
  end

  function Stock:get(options)
    local period_start = options and options.period_start or
                         os.time{year=2015, month=6, day=22, hour=10}
    local period_stop  = options and options.period_stop or
                         os.time()
    local interval     = options and options.interval or
                         '1m'

    local url = (api_url):format(self.symbol, period_start, period_stop, interval)
    local json = https.request(url)
    local jsontable = cjson.decode(json)
    local result = jsontable.chart.result[1]
    local data = result.indicators.quote[1]

    for i,timestamp in ipairs(result.timestamp) do
      local quote = Quote.new(timestamp,
                          data.open[i],
                          data.low[i],
                          data.high[i],
                          data.close[i],
                          data.volume[i])

      table.insert(self.quotes, quote)
    end

    return self
  end
end

-- Main
do
  local stock = Stock.new('TIMP3.SA'):get{ interval = '2m' }
  
  print(stock.symbol)
  for i,quote in ipairs(stock.quotes) do
    local result = ('%s - O: %.2f H: %.2f L: %.2f C: %.2f V: %s'):format(
                     quote.datetime, quote.open,
                     quote.high, quote.low,
                     quote.close, quote.volume)

    print(result)
  end
end
