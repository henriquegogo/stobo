package = 'stobo'
version = '0.1-1'
source = { url = '*' }
dependencies = {
  'lua ~> 5.1',
  'inspect', 'luasocket', 'luazip',
  'lua-gnuplot', 'lgi', 'ansicolors'
}
build = { type = 'make' }
