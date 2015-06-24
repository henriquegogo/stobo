#!./bin/lua

local inspect = require 'inspect'
local http = require 'socket.http'
local https = require 'ssl.https'
local cjson = require 'cjson'
local colors = require 'ansicolors'

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
  local string_to_time = function(datetime_string)
    return os.time{year = tonumber(datetime_string:sub(1,4)),
                   month = tonumber(datetime_string:sub(5,6)),
                   day = tonumber(datetime_string:sub(7,8)),
                   hour = 0}
  end

  function Stock.symbol(symbol)
    local self = setmetatable({}, { __index = Stock })
    
    self.symbol = symbol
    self.quotes = {}

    return self
  end

  function Stock:get(options)
    local period_start = options and options.period_start and
                         string_to_time(options.period_start) or os.time()

    local period_stop  = options and options.period_stop and 
                         string_to_time(options.period_stop) or os.time()

    local interval     = options and options.interval or '15m'

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

  function Stock:output()
    -- Candle: ——▆▆▆▆▆————
    local output = self.symbol..'\n'

    local lowest_ever = 99999999999
    for i,quote in ipairs(self.quotes) do
      if quote.low ~= 0 and quote.low < lowest_ever then
        lowest_ever = quote.low
      end
    end 
    
    for i,quote in ipairs(self.quotes) do
      local result = ('%s - O: %5s H: %5s L: %5s C: %5s V: %7s'):format(
                       quote.datetime,
                       ('%.2f'):format(quote.open),
                       ('%.2f'):format(quote.high),
                       ('%.2f'):format(quote.low),
                       ('%.2f'):format(quote.close),
                       quote.volume)

      local last_quote = self.quotes[i-1]

      --[[
      local close_color = last_quote and quote.close > last_quote.close and '%{greenbg}'
                 or last_quote and quote.close < last_quote.close and '%{redbg}'
                 or '%{black whitebg}'
      ]]

      local candle_color = quote.close > quote.open and '%{green}'
                        or quote.close < quote.open and '%{red}'
                        or '%{white}'

      -- Candle design
      local candle = (' '):rep( math.floor(quote.low*100 - lowest_ever*100 + 0.5) )

      if quote.close > quote.open then
        candle = candle..('—'):rep( math.floor(quote.open *100 - quote.low  *100 + 0.5) )
        candle = candle..('▆'):rep( math.floor(quote.close*100 - quote.open *100 + 0.5) )
        candle = candle..('—'):rep( math.floor(quote.high *100 - quote.close*100 + 0.5) )

      elseif quote.close < quote.open then
        candle = candle..('—'):rep( math.floor(quote.close*100 - quote.low  *100 + 0.5) )
        candle = candle..('▆'):rep( math.floor(quote.open *100 - quote.close*100 + 0.5) )
        candle = candle..('—'):rep( math.floor(quote.high *100 - quote.open *100 + 0.5) )

      else
        candle = candle..('—'):rep( math.floor(quote.close*100 - quote.low  *100 + 0.5) )
        candle = candle..'|'
        candle = candle..('—'):rep( math.floor(quote.high *100 - quote.open *100 + 0.5) )
      end

      output = output..result..' '..colors(candle_color..candle)..'\n'
    end

    output = output..'Lowest ever: '..lowest_ever

    return output
  end
end

-- Main
do
  local stock = Stock.symbol('TIMP3.SA'):get{ interval = '2m', period_start = '20150622' }
  print( stock:output() )
end
