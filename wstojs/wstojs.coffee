# interpreter
fs=require 'fs'
util=require 'util'
colors=require 'colors'
parser=require '../js/parser'
idtm=require '../js/idtm'
compile=require '../ws/compile'


debug=false
i=process.argv.indexOf "--debug"
if i>=0
    process.argv.splice i,1
    debug=true
fs.readFile process.argv[2],{encoding:"utf8"},(err,data)->
    if err?
        throw err
    p=new parser.JSParser
    sts=p.parse data

    compiler=new idtm.Compiler
    result=compiler.compile sts
    if debug
        console.log util.inspect(result,depth:4).grey
    compiler2=new compile.Compiler
    result2=compiler2.compile result
    #console.log result2
    for op in result2
        process.stdout.write op.getCode()





