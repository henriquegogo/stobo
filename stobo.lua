#!./bin/lua

local inspect = require 'inspect'
local http = require 'socket.http'
local zip = require 'zip'

-- Database
Database = {} do
  local source_url = 'http://www.bmfbovespa.com.br/InstDados/SerHist/'
  local database_folder = 'data/'
  local filename_pattern = 'COTAHIST_%s%s'

  function lastWorkingDay()
    local working_day = os.date('*t')

    if working_day.wday == 7 then
      working_day.day = working_day.day - 1
    elseif working_day.wday == 1 then
      working_day.day = working_day.day - 2
    end

    return os.date('%d%m%Y', os.time(working_day))
  end

  function downloadData(filename)
    print 'Downloading file...'
    local binary = http.request(source_url..filename..'.ZIP')
    local file = io.open(database_folder..filename..'.ZIP', "w")
    file:write(binary)
    file:close()
  end

  function readData(filename)
    print 'Reading file...'
    local file = zip.openfile(database_folder..filename..'/'..filename..'.TXT')
    return file:read('*a')
  end

  function fileExist(filename)
    local file_path = database_folder..filename..'.ZIP'
    return os.rename(file_path, file_path)
  end

  function Database.get(date_string)
    if not date_string then date_string = lastWorkingDay() end

    local letter_abbrev = #date_string == 4 and 'A' or
                          #date_string == 6 and 'M' or
                          #date_string == 8 and 'D'

    local filename = string.format(filename_pattern, letter_abbrev, date_string)

    if not fileExist(filename) then
      downloadData(filename)
    end
    
    return readData(filename)
  end
end

-- Stock
Stock = {} do
  local FATCOT = {
    ['0000001'] = 'COTAÇÃO UNITÁRIA',
    ['0001000'] = 'COTAÇÃO POR LOTE DE MIL AÇÕES'
  }

  local CODBDI = {
    ['02'] = 'LOTE PADRÃO',
    ['06'] = 'CONCORDATÁRIAS',
    ['10'] = 'DIREITOS E RECIBOS',
    ['12'] = 'FUNDOS IMOBILIÁRIOS',
    ['14'] = 'CERTIFIC. INVESTIMENTO / DEBÊNTURES / TÍTULOS DIVIDA PÚBLICA',
    ['18'] = 'OBRIGAÇÕES',
    ['22'] = 'BÔNUS (PRIVADOS)',
    ['26'] = 'APÓLICES / BÔNUS / TÍTULOS PÚBLICOS',
    ['32'] = 'EXERCÍCIO DE OPÇÕES DE COMPRA DE ÍNDICE',
    ['33'] = 'EXERCÍCIO DE OPÇÕES DE VENDA DE ÍNDICE',
    ['38'] = 'EXERCÍCIO DE OPÇÕES DE COMPRA',
    ['42'] = 'EXERCÍCIO DE OPÇÕES DE VENDA',
    ['46'] = 'LEILÃO DE TÍTULOS NÃO COTADOS',
    ['48'] = 'LEILÃO DE PRIVATIZAÇÃO',
    ['50'] = 'LEILÃO',
    ['51'] = 'LEILÃO FINOR',
    ['52'] = 'LEILÃO FINAM',
    ['53'] = 'LEILÃO FISET',
    ['54'] = 'LEILÃO DE AÇÕES EM MORA',
    ['56'] = 'VENDAS POR ALVARÁ JUDICIAL',
    ['58'] = 'OUTROS',
    ['60'] = 'PERMUTA POR AÇÕES',
    ['61'] = 'META',
    ['62'] = 'TERMO',
    ['66'] = 'DEBÊNTURES COM DATA DE VENCIMENTO ATÉ 3 ANOS',
    ['68'] = 'DEBÊNTURES COM DATA DE VENCIMENTO MAIOR QUE 3 ANOS',
    ['70'] = 'FUTURO COM MOVIMENTAÇÃO CONTÍNUA',
    ['71'] = 'FUTURO COM RETENÇÃO DE GANHO',
    ['74'] = 'OPÇÕES DE COMPRA DE ÍNDICES',
    ['75'] = 'OPÇÕES DE VENDA DE ÍNDICES',
    ['78'] = 'OPÇÕES DE COMPRA',
    ['82'] = 'OPÇÕES DE VENDA',
    ['83'] = 'DEBÊNTURES E NOTAS PROMISSÓRIAS',
    ['96'] = 'FRACIONÁRIO',
    ['99'] = 'TOTAL GERAL'
  }

  local INDOPC = {
    ['0'] = '',
    ['1'] = 'US$ CORREÇÃO PELA TAXA DO DÓLAR',
    ['2'] = 'TJLP CORREÇÃO PELA TJLP',
    ['3'] = 'TR CORREÇÃO PELA TR',
    ['4'] = 'IPCR CORREÇÃO PELO IPCR',
    ['5'] = 'SWA OPÇÕES DE TROCA - SWOPTIONS',
    ['6'] = 'ÍNDICES (PONTOS) OPÇÕES REFERENCIADAS EM PONTOS DE  ÍNDICE',
    ['7'] = 'US$ (PROTEGIDAS) CORREÇÃO PELA TAXA DO DÓLAR - OPÇÕES PROTEGIDAS',
    ['8'] = 'IGPM (PROTEGIDA) CORREÇÃO PELO IGP - M - OPÇÕES PROTEGIDAS',
    ['9'] = 'URV CORREÇÃO PELA URV'
  }

  local TPMERC = {
    ['010'] = 'VISTA',
    ['012'] = 'EXERCÍCIO DE OPÇÕES DE COMPRA',
    ['013'] = 'EXERCÍCIO DE OPÇÕES DE VENDA',
    ['017'] = 'LEILÃO',
    ['020'] = 'FRACIONÁRIO',
    ['030'] = 'TERMO',
    ['050'] = 'FUTURO COM RETENÇÃO DE GANHO',
    ['060'] = 'FUTURO COM MOVIMENTAÇÃO CONTÍNUA',
    ['070'] = 'OPÇÕES DE COMPRA',
    ['080'] = 'OPÇÕES DE VENDA'
  }

  function trimZeroes(text)
    local withoutSpaces = text:gsub("^%s*(.-)%s*$", "%1")
    local withoutInspaces = withoutSpaces:gsub("  *", " ")
    local withoutLeftZeroes = withoutInspaces:gsub("^0*", "")  

    return withoutLeftZeroes
  end

  function toDecimal(number)
    if #number > 0 then
      number = string.format("%03d", number)
      number = number:sub(1, -3) ..'.'.. number:sub(-2)
    end

    return number
  end

  function Stock.new(line_string)
    local self = setmetatable({}, { __index = Stock })

    self.TIPREG = trimZeroes(  line_string:sub(1, 2)  )
    self.DATAPR = trimZeroes( line_string:sub(3, 10) )
    self.CODBDI = CODBDI[ line_string:sub(11, 12) ]
    self.CODNEG = trimZeroes( line_string:sub(13, 24) )
    self.TPMERC = TPMERC[ line_string:sub(25, 27) ]
    self.NOMRES = trimZeroes( line_string:sub(28, 39) )
    self.ESPECI = trimZeroes( line_string:sub(40, 49) )
    self.PRAZOT = trimZeroes( line_string:sub(50, 52) )
    self.MODREF = trimZeroes( line_string:sub(53, 56) )
    self.PREABE = toDecimal( trimZeroes( line_string:sub(57, 69) ) )
    self.PREMAX = toDecimal( trimZeroes( line_string:sub(70, 82) ) )
    self.PREMIN = toDecimal( trimZeroes( line_string:sub(83, 95) ) )
    self.PREMED = toDecimal( trimZeroes( line_string:sub(96, 108) ) )
    self.PREULT = toDecimal( trimZeroes( line_string:sub(109, 121) ) )
    self.PREOFC = toDecimal( trimZeroes( line_string:sub(122, 134) ) )
    self.PREOFV = toDecimal( trimZeroes( line_string:sub(135, 147) ) )
    self.TOTNEG = trimZeroes( line_string:sub(148, 152) )
    self.QUATOT = trimZeroes( line_string:sub(153, 170) )
    self.VOLTOT = trimZeroes( line_string:sub(171, 188) )
    self.PREEXE = toDecimal( trimZeroes( line_string:sub(189, 201) ) )
    self.INDOPC = INDOPC[ line_string:sub(202, 202) ]
    self.DATVEN = trimZeroes( line_string:sub(203, 210) )
    self.FATCOT = FATCOT[ line_string:sub(211, 217) ]
    self.PTOEXE = trimZeroes( line_string:sub(218, 230) )
    self.CODISI = trimZeroes( line_string:sub(231, 242) )
    self.DISMES = trimZeroes( line_string:sub(243, 245) )

    return self
  end
end

-- StockList
StockList = {} do
  function StockList.new(data)
    local self = setmetatable({}, { __index = StockList })
    
    self.stocks = {}

    if type(data) == 'string' then
      print 'Proccessing stock list as string...'

      for line_string in data:gmatch('[^\r\n]+') do
        if not string.match(line_string, 'COTAHIST') then
          table.insert(self.stocks, Stock.new(line_string))
        end
      end

    elseif type(data) == 'table' then
      print 'Proccessing stock list as table...'

      self.stocks = data
    end

    return self
  end

  function StockList:byCriteria(criteria)
    print 'Filtering search...'

    local filtred_stocks = {}

    for i,stock in pairs(self.stocks) do
      if criteria(stock) then
        table.insert(filtred_stocks, stock)
      end
    end

    return StockList.new(filtred_stocks)
  end

  function StockList:bySymbol(symbol)
    local criteria = function(stock)
      return stock.CODNEG == symbol
    end

    return self:byCriteria(criteria)
  end

  function StockList:byDate(date)
    local criteria = function(stock)
      return stock.DATAPR == date
    end

    return self:byCriteria(criteria)
  end

  function StockList:byStartDate(date)
    local criteria = function(stock)
      return tonumber(stock.DATAPR) >= tonumber(date)
    end

    return self:byCriteria(criteria)
  end

  function StockList:byEndDate(date)
    local criteria = function(stock)
      return tonumber(stock.DATAPR) <= tonumber(date)
    end

    return self:byCriteria(criteria)
  end
end

-- Main
do
  print 'Opening or downloading database...'
  local data_text = Database.get('2015')
  print 'Proccessing database...'
  local stockList = StockList.new(data_text)
  print 'Done'

  -- print(inspect( stocks:bySymbol('PETR4') ))
  print(inspect( stockList:byDate('20150605'):bySymbol('PETR4') ))
  print(inspect( stockList:bySymbol('PETR4')
                          :byStartDate('20150301')
                          :byCriteria(function(stock)
                            return tonumber(stock.PREMAX) > 13
                          end)))
end
