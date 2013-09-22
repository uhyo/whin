fs=require 'fs'
class IO
    readChar:(callback)->
    readLine:(callback)->
    readAll:(callback)->
    end:->
    write:(str)->
exports.FileLoader=class extends IO
    load:(@filepath,callback)->
        fs.readFile @filepath,{encoding:"utf8"},(err,data)=>
            if err?
                throw err
            # 改行コードをLFに統一
            @data=data.replace(/\r\n/g,"\n").replace(/\r/g,"")
            callback()
    readChar:(callback)->
        if @data.length
            char=@data[0]
            @data=@data.slice 1
            callback char
        else
            callback null
    readLine:(callback)->
        if @data.length
            result=@data.match /^(.*)(?:\n|$)/
            if result?
                line=result[1]
                @data=@data.slice result[0].length
                callback line
            else
                callback null
        else
            callback null
    readAll:(callback)->
        data=@data
        @data=""
        callback data
exports.Console=class extends IO
    constructor:->
        process.stdin.setEncoding "utf8"
        process.stdin.setRawMode true
    end:->
        process.exit(0)
    write:(str)->
        process.stdout.write str
    readChar:(callback)->
        char=process.stdin.read 1
        if char?
            callback char
        else
            process.stdin.resume()
            process.stdin.once "data",(chunk)->
                if chunk=="\u0003"
                    # Ctrl-C
                    process.exit 0
                if chunk=="\r"
                    chunk="\n"
                process.stdin.pause()
                process.stdout.write chunk
                callback chunk
    readLine:(callback)->
        line=""
        check= =>
            @readChar (char)->
                line+=char
                if char=="\n"
                    callback line
                    return
                check()
        check()

