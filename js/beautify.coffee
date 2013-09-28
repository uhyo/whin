# interpreter
parser=require './parser'
fs=require 'fs'

fs.readFile process.argv[2],{encoding:"utf8"},(err,data)->
    if err?
        throw err
    p=new parser.JSParser
    sts=p.parse data
    manager=new parser.TokenizeManager
    tokens=manager.tokenize sts
    console.log tokens.toString()





