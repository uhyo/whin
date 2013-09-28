# interpreter
environment=require './environment'
io=require './io'

debug=null
i=process.argv.indexOf "--debug"
if i>=0
    if process.argv.length>4
        debug=process.argv[i+1]
        process.argv.splice i,2
    else
        debug="full"
        process.argv.splice i,1

if process.argv.length<3
    console.error "No file specified."
    process.exit 0
else
    env=new environment.WSEnvironment new io.Console
    if debug
        env.debug debug
    env.loadFile process.argv[2],->
        if env.debugMode=="parse"
            process.exit 0
        else
            env.run()


