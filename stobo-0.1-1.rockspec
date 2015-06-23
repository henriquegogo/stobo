package = 'stobo'
version = '0.1-1'
source = { url = 'Stobo Repository' }
dependencies = {
  'lua ~> 5.1',
  'inspect', 'luasocket', 'luazip',
  'lua-gnuplot', 'lgi', 'ansicolors',
  'luasec', 'lua-cjson'
}
build = { type = 'make' }
