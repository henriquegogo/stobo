Quote = {} do
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
      number = ('%03d'):format(number)
      number = number:sub(1, -3) ..'.'.. number:sub(-2)
    end

    return number
  end

  function Quote.new(line_string)
    local self = setmetatable({}, { __index = Quote })

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

    local simple_format = {
      date   = self.DATAPR,
      symbol = self.CODNEG,
      open   = self.PREABE,
      high   = self.PREMAX,
      low    = self.PREMIN,
      close  = self.PREULT,
      volume = self.VOLTOT
    }

    return simple_format
  end
end
