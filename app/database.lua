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
    print 'Reading file from zip file...'
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

    local filename = (filename_pattern):format(letter_abbrev, date_string)

    if not fileExist(filename) then
      downloadData(filename)
    end
    
    return readData(filename)
  end
end
