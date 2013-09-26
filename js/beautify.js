// Generated by CoffeeScript 1.6.3
(function() {
  var fs, parser;

  parser = require('./parser');

  fs = require('fs');

  fs.readFile(process.argv[2], {
    encoding: "utf8"
  }, function(err, data) {
    var manager, p, sts, tokens;
    if (err != null) {
      throw err;
    }
    p = new parser.JSParser;
    sts = p.parse(data);
    manager = new parser.TokenizeManager;
    tokens = sts.tokenize(manager);
    return console.log(tokens.toString());
  });

}).call(this);
