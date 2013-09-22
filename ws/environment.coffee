io=require './io'
operations=require './operations'
class Program
    constructor:(@env)->
        @pointer=0
        @ops=[]
    load:(io,callback)->
        @parser=new operations.Parser @env,io
        @parser.parse (ops)=>
            @ops=ops
            callback()
    run:->
        env=@env
        debug=env.debugMode
        ops=@ops
        while true
            op=ops[@pointer]
            if debug
                process.stdout.write "step#{@pointer}:".yellow
                op.log env
            unless op?
                # ぶじ終了した?
                process.exit 0
                break
            if op.on
                # コールバックのいらないやつ
                op.on env
                @pointer++
            else if op.run
                # コールバックいるやつ
                op.run env,=>
                    @pointer++
                    @run()
                break
            else
                @pointer++
    step:(callback)->
        @getOperation @pointer,(op)=>
            op.run @env,=>
                @pointer++
                callback()
    getOperation:(cursor,callback)->
        # その位置の命令を得る
        if @ops.length>cursor
            callback @ops[cursor]
            return
        # そこまでない
        index=@ops.length
        check= =>
            @parser.nextOperation (op)=>
                if @env.debugMode
                    console.log "(#{op})".red
                @ops[index]=op
                index++
                if index>=cursor
                    callback op
                else
                    check()
        check()
    findLabel:(label)->
        for pos in [0...(@ops.length)]
            op=@ops[pos]
            if op.isLabel label
                return pos
        throw new Error "Cannot find label '#{label}'"
class WSEnvironment
    constructor:(@io)->
        @stack=[]   #number[]
        @heap={}    #{(number):number}
        @callstack=[]
        @labels={}
        @program=new Program this
        @debugMode=null    #デバッグモードなら文字列
    loadFile:(filepath,callback)->
        loader=new io.FileLoader
        loader.load filepath,=>
            @program.load loader,->
                callback()
    debug:(@debugMode)->
        if @debugMode
            require 'colors'
    # 実行する
    run:->
        @program.run()
    # ラベルの位置を探す
    findLabel:(label)->
        if @labels[label]?
            @labels[label]
        else
            pos=@program.findLabel label
            @labels[label]=pos
            pos
    # スタック操作
    push:(number)->
        @stack.push number
        return
    pop:(number)->
        @sassure 1
        @stack.pop()
    # スタックの一番上
    top:->
        @stack[@stack.length-1] || 0
    # スタックの上から何番目
    nth:(n)->
        ref=@stack[@stack.length-1-n]
        unless ref?
            throw new Error "Stack underflow"
        ref
    # スタックのn番目まであることを保証
    sassure:(n)->
        if @stack.length<n || n<0
            throw new Error "Stack underflow"

    # Heap
    store:(pos,value)->
        @heap[pos]=value
    retrieve:(pos)->
        ref=@heap[pos] || 0
        ###
        unless ref?
            throw new Error "Heap overflow"
        ref
        ###

exports.WSEnvironment=WSEnvironment
