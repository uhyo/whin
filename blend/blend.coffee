# interpreter
parser=require '../js/parser'
fs=require 'fs'
io=require '../ws/io'
operations=require '../ws/operations'
manager=require './manager'
colors=require 'colors'

fs.readFile process.argv[2],{encoding:"utf8"},(err,data)->
    if err?
        throw err
    p=new parser.JSParser
    sts=p.parse data
    wsmanager=new manager.WSManager
    tokens=wsmanager.tokenize sts
    #console.log tokens.toString().grey
    loader=new io.FileLoader
    loader.load process.argv[3],->
        wsparser=new operations.Parser loader
        wsparser.parse false,(ops)->
            blender=new manager.Blender 8,8,tokens,ops
            code=blender.blend()

            console.log code#.replace(/\u0020/g,"[SP]".grey).replace(/\t/g,"[TB]".grey)





