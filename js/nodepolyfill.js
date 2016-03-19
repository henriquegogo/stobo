function require(lib) {
  if (lib == 'fs') {
    return new FileSystem();
  }
}

function FileSystem() {}
FileSystem.prototype.readFileSync = function(filepath) {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", filepath, false);
  xhr.send();
  
  return xhr.responseText;
}
