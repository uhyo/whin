// Generated by CoffeeScript 1.6.3
(function() {
  var colors, fs, io, manager, operations, parser;

  parser = require('../js/parser');

  fs = require('fs');

  io = require('../ws/io');

  operations = require('../ws/operations');

  manager = require('./manager');

  colors = require('colors');

  fs.readFile(process.argv[2], {
    encoding: "utf8"
  }, function(err, data) {
    var loader, p, sts, tokens, wsmanager;
    if (err != null) {
      throw err;
    }
    p = new parser.JSParser;
    sts = p.parse(data);
    wsmanager = new manager.WSManager;
    tokens = wsmanager.tokenize(sts);
    loader = new io.FileLoader;
    return loader.load(process.argv[3], function() {
      var wsparser;
      wsparser = new operations.Parser(loader);
      return wsparser.parse(false, function(ops) {
        var blender, code;
        blender = new manager.Blender(4, 4, tokens, ops, 2);
        code = blender.blend();
        return process.stdout.write(code);
      });
    });
  });

}).call(this);
