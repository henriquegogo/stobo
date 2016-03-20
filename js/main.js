"use strict";

var fs = require('fs');

function Tick(date, open, high, low, close, volume) {
  if (arguments.length == 1 && Array.isArray(arguments[0]) ) {
    var tickArray = arguments[0];
    date   = tickArray[0];
    open   = tickArray[1];
    high   = tickArray[2];
    low    = tickArray[3];
    close  = tickArray[4];
    volume = tickArray[6];
  }

  this.date   = date;
  this.open   = parseFloat(open).toFixed(1);
  this.high   = parseFloat(high).toFixed(1);
  this.low    = parseFloat(low).toFixed(1);
  this.close  = parseFloat(close).toFixed(1);
  this.volume = volume;
}

function Stock(name) {
  var self = this;
  self.ticks = [];

  var fileBuffer = fs.readFileSync('./'+name+'.csv', 'utf16le');
  var fileString = fileBuffer.toString();
  var linesArray = fileString.split('\r\n');
  linesArray.pop();

  linesArray.forEach(function(value) {
    var tickArray = value.split(',');
    var tick = new Tick(tickArray);
    self.ticks.push(tick);
  });

  self.initial_time = self.ticks[0].date;
  self.final_time = self.ticks[self.ticks.length - 1].date;
  self.quote = name;
}
Stock.prototype = Indicators.prototype;

function Indicators() {}
Indicators.prototype.ticksWithIndicators = function(indicators) {
  var ticksWithIndicators = [];

  this.ticks.forEach(function(value) {
    ticksWithIndicators.push( JSON.parse(JSON.stringify(value)) );
  });

  for (var i in ticksWithIndicators) {
    for (var key in indicators) {
      ticksWithIndicators[i][key] = indicators[key][i];
    }
  }

  return ticksWithIndicators;
}
Indicators.prototype.ma = function(period) {
  var output = [];
  var period = period || 12;

  for (var i in this.ticks) {
    if (i >= period) {
      var ma = 0.0;
      for (var a = i; a > i-period; a--) {
        ma = parseFloat(ma) + parseFloat(this.ticks[a].close);
      }
      ma = ma / period;
      output.push(ma.toFixed(4));
    }
    else {
      output.push(0.0000);
    }
  }

  return output;
}

function tester(stock) {
  function buy(price) {
    console.log('Buy: ' + price);
  }

  function sell(price) {
    console.log('Sell: ' + price);
  }

  var ticks = stock.ticksWithIndicators({ ma8: stock.ma(8), ma20: stock.ma(20) });
  for (var i in ticks) {
    if ( ticks[i].ma8 == ticks[i].ma20 != 0 ) {
      if ( ticks[i-1] && ticks[i-1].ma8 < ticks[i].ma8 ) buy(ticks[i].low);
      if ( ticks[i-1] && ticks[i-1].ma8 > ticks[i].ma8 ) sell(ticks[i].high);
    }
  }
}

var stock = new Stock('WDO');
tester(stock);
