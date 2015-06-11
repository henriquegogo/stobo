Stocks = {} do
  function Stocks.new(data, symbol)
    local self = setmetatable({}, { __index = Stocks })
   
    if type(data) == 'string' then
      print 'Proccessing database...'
      
      self.quotes = {}

      for line_string in data:gmatch('[^\r\n]+') do
        if not string.match(line_string, 'COTAHIST') then
          local quote = Quote.new(line_string)

          table.insert(self.quotes, quote)
        end
      end

    elseif type(data) == 'table' then
      self.quotes = data
      self.symbol = symbol
    end

    return self
  end

  function Stocks:byCriteria(criteria)
    print 'Filtering search...'

    local filtred_quotes = {}
    local symbol = false

    for i,quote in pairs(self.quotes) do
      local validation = criteria(quote)
      if validation then
        table.insert(filtred_quotes, quote)
        symbol = type(validation) == 'string' and validation
      end
    end

    local stocks = Stocks.new(filtred_quotes, self.symbol)
    if symbol then stocks.symbol = symbol end
    
    return stocks
  end

  function Stocks:bySymbol(symbol)
    local criteria = function(quote)
      return quote.symbol == symbol and symbol
    end

    return self:byCriteria(criteria)
  end

  function Stocks:byDate(date)
    local criteria = function(quote)
      return quote.date == date
    end

    return self:byCriteria(criteria)
  end

  function Stocks:byStartDate(date)
    local criteria = function(quote)
      return quote.date and tonumber(quote.date) >= tonumber(date)
    end

    return self:byCriteria(criteria)
  end

  function Stocks:byEndDate(date)
    local criteria = function(quote)
      return quote.date and tonumber(quote.date) <= tonumber(date)
    end

    return self:byCriteria(criteria)
  end

  function Stocks:SMA(period)
    local sma_list = {}
    local last_x = {}

    for i,quote in pairs(self.quotes) do
      table.insert(last_x, quote.close)
      if #last_x > period then table.remove(last_x, 1) end

      local price_sum = 0.0
      for i,price in pairs(last_x) do
        price_sum = price_sum + price
      end
      local sma = string.format('%.2f', price_sum / period)

      table.insert(sma_list, sma)
    end

    return sma_list
  end
end
