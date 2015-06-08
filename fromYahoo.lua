#!./bin/lua

local inspect = require 'inspect'
local http = require 'socket.http'
local https = require 'ssl.https'
local cjson = require 'cjson'
local driver = require 'luasql.sqlite3'

local api_url = 'https://finance-yql.media.yahoo.com/v7/finance/chart/%s?period1=%s&period2=%s&interval=%s'
local db_file = 'db.sqlite'

-- Indicator
Indicator = {} do
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

  function Indicator.new(timestamp, open, low, high, close, volume)
    local self = setmetatable({}, { __index = Indicator })

    self.datetime = os.date('%c', timestamp)
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
  local symbol = 'PETR4.SA'
  local period_start = os.time{year=2015, month=1, day=2, hour=10}
  local period_stop = os.time()
  local interval = '1m'

  function Stock.new(symbol)
    local self = setmetatable({}, { __index = Stock })
    
    self.symbol = symbol
    self.indicators = {}

    return self
  end

  function Stock:update()
    local url = string.format(api_url, symbol, period_start, period_stop, interval)
    local json = https.request(url)
    local table = cjson.decode(json)
    local result = table.chart.result[1]
    local data = result.indicators.quote[1]

    for i,timestamp in ipairs(result.timestamp) do
      local indicator = Indicator.new(timestamp,
                          data.open[i],
                          data.low[i],
                          data.high[i],
                          data.close[i],
                          data.volume[i])

      self.indicators[timestamp] = indicator
    end

    return self:save()
  end

  function Stock:save()
    local env = driver.sqlite3()
    local db = env:connect(db_file)

    db:execute[[
      CREATE TABLE stocks(
        symbol TEXT,
        timestamp NUMERIC,
        datetime TEXT,
        open REAL,
        low REAL,
        close REAL,
        volume NUMERIC
      )
    ]]
    
    for timestamp,indicator in pairs(self.indicators) do
      db:execute(string.format([[
        INSERT INTO stocks VALUES('%s', %u, '%s', %g, %g, %g, %u)
      ]], self.symbol, timestamp, indicator.datetime,
          indicator.open, indicator.low,
          indicator.close, indicator.volume))
    end

    db:close()
    env:close()

    return self
  end

  function Stock:restore()
    return self
  end
end

-- Main
do
  local petrobras = Stock.new('PETR4.SA'):update()
  print(inspect(petrobras))
end

