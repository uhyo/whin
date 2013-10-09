class Operation
    ###
    on:(env)->
    run:(env,callback)->
        @log env
        @on env
        callback()
    ###
    #on: no callback; run:callback
    @code:""
    log:(env)->
        if env.debugMode
            console.log @toString().blue
    isLabel:(label)->false
    toString:->
        @constructor.name
    getCode:->
        @constructor.code

class NumberParamed extends Operation
    @param:"number"
    constructor:(@number)->
        #@number: number
    toString:->
        "#{super}(#{@number})"
    getCode:->
        # numを数値化
        result=""
        num=Math.abs @number
        while num>0
            if num%2==1
                result="\t"+result
                num--
            else
                result=" "+result
            num/=2
        if @number>=0
            result=" "+result+"\n"
        else
            result="\t"+result+"\n"
        @constructor.code+result

class LabelParamed extends Operation
    @param:"label"
    constructor:(@label)->
        #@label: string
    toString:->
        "#{super}(#{@label.replace(/\t/g,'[TB]').replace(/\s/g,'[SP]')})"
    getCode:->
        @constructor.code+@label+"\n"

# 命令たち
ops=exports=module.exports=
    # スタック操作
    stack:
        Push:class Push extends NumberParamed
            on:(env)->
                env.push @number
        Duplicate:class Duplicate extends Operation
            on:(env)->
                env.push env.stack[env.stack.length-1]
        Copy:class Copy extends NumberParamed
            on:(env)->
                env.push env.nth @number
        Swap:class Swap extends Operation
            on:(env)->
                env.sassure 1
                le=env.stack.length-1
                tmp=env.stack[le]
                env.stack[le]=env.stack[le-1]
                env.stack[le-1]=tmp
        Discard:class Discard extends Operation
            on:(env)->
                env.sassure 0
                env.pop()
        Slide:class Slide extends NumberParamed
            on:(env)->
                stack=env.stack
                idx=stack.length-1-@number
                env.sassure @number
                env.stack.splice idx,@number
    arithmetic:
        Add:class Add extends Operation
            on:(env)->
                env.sassure 1
                ls=env.stack.length-1
                env.stack[ls-1]+=env.stack[ls]
                env.stack.length--
        Subtract:class Subtract extends Operation
            on:(env)->
                env.sassure 1
                ls=env.stack.length-1
                env.stack[ls-1]-=env.stack[ls]
                env.stack.length--
        Multiply:class Multiply extends Operation
            on:(env)->
                env.sassure 1
                ls=env.stack.length-1
                env.stack[ls-1]*=env.stack[ls]
                env.stack.length--
        Divide:class Divide extends Operation
            on:(env)->
                env.sassure 1
                ls=env.stack.length-1
                env.stack[ls-1]=env.stack[ls-1]/env.stack[ls] | 0
                env.stack.length--
        Modulo:class Modulo extends Operation
            on:(env)->
                env.sassure 1
                ls=env.stack.length-1
                env.stack[ls-1]%=env.stack[ls]
                env.stack.length--
    heap:
        Store:class Store extends Operation
            on:(env)->
                num=env.pop()
                pos=env.pop()
                env.store pos,num
        Retrieve:class Retrieve extends Operation
            on:(env)->
                env.push env.retrieve env.pop()
    flow:
        Label:class Label extends LabelParamed
            isLabel:(label)->
                label==@label
        Call:class Call extends LabelParamed
            on:(env)->
                pos=env.findLabel @label
                env.callstack.push env.program.pointer
                env.program.pointer=pos
        Jump:class Jump extends LabelParamed
            on:(env)->
                pos=env.findLabel @label
                env.program.pointer=pos
        JumpZero:class JumpZero extends LabelParamed
            on:(env)->
                n=env.pop()
                if n==0
                    pos=env.findLabel @label
                    env.program.pointer=pos
        JumpNegative:class JumpNegative extends LabelParamed
            on:(env)->
                n=env.pop()
                if n<0
                    pos=env.findLabel @label
                    env.program.pointer=pos
        Return:class Return extends Operation
            on:(env)->
                bt=env.callstack.pop()
                unless bt?
                    throw new Error "Callstack underflow"
                env.program.pointer=bt
        End:class End extends Operation
            on:(env)->
                env.io.end()
    io:
        OutputChar:class OutputChar extends Operation
            on:(env)->
                env.io.write String.fromCharCode env.pop()
        OutputNumber:class OutputNumber extends Operation
            on:(env)->
                env.io.write env.pop().toString 10
        ReadChar:class ReadChar extends Operation
            run:(env,callback)->
                env.io.readChar (char)->
                    env.store env.pop(),char.charCodeAt 0
                    callback()
        ReadNumber:class ReadNumber extends Operation
            run:(env,callback)->
                env.io.readLine (line)->
                    num=parseInt line
                    if isNaN num
                        throw new Error "Cannot parse number"
                    env.store env.pop(),num
                    callback()
        
exports.Parser=class Parser
    constructor:(@io)->
    readChar:(callback)->
        # Whitespace以外無視して読む
        io=@io
        check=(char)->
            
            if !char? || char in [" ","\t","\n"]
                callback char
            else
                io.readChar check
        io.readChar check
    # パースしてOperation配列を返す
    parse:(debug,callback)->
        @io.readAll (data)=>
            # パースする
            chars=""
            obj=opsTable
            index=0
            len=data.length
            operations=[]

            readChar=->
                while true
                    char=data[index]
                    if debug
                        process.stdout.write (switch char
                            when " " then "[SP]"
                            when "\t" then "[TB]"
                            when "\n" then "[LF]"
                            else String char
                        ).grey
                    index++
                    unless char in [" ","\t","\n"]
                        continue
                    return char
                return null

            readNumber=->
                num=0
                sign=0
                switch readChar()
                    when " "
                        sign=1
                    when "\t"
                        sign=-1
                    else
                        throw new Error "Invalid number"
                while true
                    char=readChar()
                    unless char?
                        throw new Error "Unexpected end of input"
                    switch char
                        when " "
                            num*=2
                        when "\t"
                            num=2*num+1
                        when "\n"
                            return num
            readLabel=->
                label=""
                while true
                    char=readChar()
                    unless char?
                        throw new Error "Unexpected end of input"
                    switch char
                        when " ","\t"
                            label+=char
                        when "\n"
                            return label

            while index<len
                char=data[index]
                if debug
                    process.stdout.write (switch char
                        when " " then "[SP]"
                        when "\t" then "[TB]"
                        when "\n" then "[LF]"
                        else String char
                    ).grey
                index++
                unless char in [" ","\t","\n"]
                    continue
                chars+=char
                obj=obj[char]
                if "function"==typeof obj
                    # 該当する命令を発見
                    op=null
                    switch obj.param
                        when "number"
                            op=new obj readNumber()
                        when "label"
                            op=new obj readLabel()
                        else
                            op=new obj
                    if debug
                        console.log op.toString().red
                    operations.push op
                    chars=""
                    obj=opsTable
                else unless obj?
                    chs=chars.replace(/\t/g,"[TB]").replace(/\n/g,"[LF]").replace(/\s/g,"[SP]")
                    throw new Error "Cannot parse '#{chs}'"

            # 終了
            if chars!=""
                chs=chars.replace(/\t/g,"[TB]").replace(/\n/g,"[LF]").replace(/\s/g,"[SP]")
                throw new Error "Cannot parse '#{chs}'"
            callback operations



    nextOperation:(callback)->
        obj=opsTable
        chars=""
        check=(char)=>
            unless char?
                # もうない
                throw new Error "Unexpected end of input"
            chars+=char
            obj=obj[char]
            if "function"==typeof obj
                # 該当する命令を発見
                switch obj.param
                    when "number"
                        @readNumber (num)->
                            callback new obj num
                    when "label"
                        @readLabel (label)->
                            callback new obj label
                    else
                        callback new obj
            else unless obj?
                chs=chars.replace(/\t/g,"[TB]").replace(/\n/g,"[LF]").replace(/\s/g,"[SP]")
                throw new Error "Cannot parse '#{chs}'"
            else
                @readChar check
        @readChar check
               
# テーブル
opsTable=
    " ":#Stack Manipulation
        " ":ops.stack.Push
        "\t":
            " ":ops.stack.Copy
            "\n":ops.stack.Slide
        "\n":
            " ":ops.stack.Duplicate
            "\t":ops.stack.Swap
            "\n":ops.stack.Discard
    "\t":
        " ":#Arithmetic
            " ":
                " ":ops.arithmetic.Add
                "\t":ops.arithmetic.Subtract
                "\n":ops.arithmetic.Multiply
            "\t":
                " ":ops.arithmetic.Divide
                "\t":ops.arithmetic.Modulo
        "\t":#Heap Access
            " ":ops.heap.Store
            "\t":ops.heap.Retrieve
        "\n":#IO
            " ":
                " ":ops.io.OutputChar
                "\t":ops.io.OutputNumber
            "\t":
                " ":ops.io.ReadChar
                "\t":ops.io.ReadNumber
    "\n":#Flow Control
        " ":
            " ":ops.flow.Label
            "\t":ops.flow.Call
            "\n":ops.flow.Jump
        "\t":
            " ":ops.flow.JumpZero
            "\t":ops.flow.JumpNegative
            "\n":ops.flow.Return
        "\n":
            "\n":ops.flow.End

(->
    chk=(obj,str)->
        for key,value of obj
            if "function"==typeof value
                # コンストラクタに自身のコード情報をつけてあげる
                value.code=str+key
            else
                chk value,str+key
        return

    chk opsTable,""
)()
