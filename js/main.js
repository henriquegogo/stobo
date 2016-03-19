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
  }

  return output;
}

var stock = new Stock('WDO');
console.log(stock.ma(20) );
