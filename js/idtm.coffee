# 変換する
parser=require './parser'

class Closure
    constructor:(@parent)->  # parent: Closure
        @variables={}
        @functions={}
    getNewLabel:->
        if @parent
            @parent.getNewLabel()
        else
            null
    getChild:->
        new Closure @
    # 変数をえる
    getVariable:(name)->
        if v=@getLocalVariable name
            v
        else if @parent?
            @parent.getLocalVariable name
        else
            null
    getLocalVariable:(name)->
        # 既に同じ変数があったらそっちを返す
        if @variables[name]?
            return @variables[name]
        null
    addVariable:(v)->
        if @parent
            @parent.addVariable v
        else
            @addLocalVariable v
    addLocalVariable:(v)->
        if v.name?
            @variables[v.name]=v
    addFunction:(func)->
        if func.name?
            @functions[func.name]=func
    getFunction:(name)->
        @functions[name] ? @parent?.getFunction name


class GlobalClosure extends Closure
    constructor:->
        super null
        @labels=[]
        @nextLabelNumber=0
    getNewLabel:->
        n=new Label @nextLabelNumber++
        @labels.push n
        n

# 新しいやつをコンパイル
class Compiler
    constructor:->
        @closure=new GlobalClosure
        @result=[]  #[Operation]
        # ループスタック
        @reservedLabelNames=[] #LabelledStatement用
        @iterationStack=[]  # [IterationManager]
        # 関数定義スタック
        @funcStack=[]   # [Func]
        # 得な伊豆用
        @tma=new parser.TokenizeManager
    compile:(statements)->
        # parser.Statements
        @statements statements,true
        return @result
    statements:(obj,mainmode)->
        # mainmode:終了したらendするか
        if obj instanceof parser.Statements
            funcs=[]
            if obj instanceof parser.SourceElements
                for el in obj
                    if el instanceof parser.FunctionDeclaration
                        funcs.push @closure.addFunction @makeFunction el
            # 各文をアレする
            obj.forEach @main.bind @
            if mainmode
                # 先にはいかせないぜ！
                @result.push new End
            # 関数定義を展開する
            for f in funcs
                @codeFunction f

    # Statementの処理
    main:(obj)->
        if obj instanceof parser.BlockStatement
            @statements obj.statements,false
        else if obj instanceof parser.VariableStatement
            for vararr in obj.variables
                v=@getLocalVariable vararr[0].value
                if vararr[1]?
                    # 中身ある
                    @substitute v,@calc vararr[1]
        else if obj instanceof parser.EmptyStatement
        else if obj instanceof parser.ExpressionStatement
            # ダミーに代入しておく
            cres=@calc obj.exp
            unless cres instanceof Variable && cres.name?
                # 代入されていないのでしておく
                tmpv=@getTempVariable()
                @substitute tmpv,cres
        else if obj instanceof parser.IfStatement
            falselabel = @getNewLabel()
            endlabel=null
            cond=@calc obj.condition
            @jumpunless cond,falselabel
            @main obj.truestatement
            if obj.elsestatement?
                # elseがある
                endlabel= @getNewLabel()
                @jump endlabel
            @labelhere falselabel
            if obj.elsestatement?
                @main obj.elsestatement
                @labelhere endlabel
        else if obj instanceof parser.Do_WhileStatement
            backlabel = @getNewLabel()
            endlabel  = @getNewLabel()
            @labelhere backlabel
            @manageIteration (=>
                # メイン処理
                @main obj.statement
                cond=@calc obj.condition
                @jumpif cond,backlabel
                @labelhere endlabel
            ),(=>
                # continue時
                @jump backlabel
            ),(=>
                #break時
                @jump endlabel
            )
        else if obj instanceof parser.WhileStatement
            backlabel = @getNewLabel()
            endlabel = @getNewLabel()
            @manageIteration (=>
                @labelhere backlabel
                cond=@calc obj.condition
                @jumpunless cond,endlabel
                @main obj.statement
                @jump backlabel
                @labelhere endlabel
            ),(=>
                @jump backlabel
            ),(=>
                @jump endlabel
            )
        else if obj instanceof parser.ForStatement
            if obj.exp1?
                @calc obj.exp1
            backlabel = @getNewLabel()
            nextlabel = @getNewLabel()
            endlabel  = @getNewLabel()

            @manageIteration (=>
                @labelhere backlabel
                cond=if obj.exp2?
                    @calc obj.exp2
                else
                    new Literal true
                @jumpunless cond,endlabel
                @main obj.statement
                @labelhere nextlabel
                if obj.exp3?
                    @calc obj.exp3
                @jump backlabel
                @labelhere endlabel
            ),(=>
                @jump nextlabel
            ),(=>
                @jump endlabel
            )
        else if obj instanceof parser.For_VarStatement
            vari=new parser.VariableStatement
            vari.variables=obj.variables
            @main vari
            backlabel = @getNewLabel()
            nextlabel = @getNewLabel()
            endlabel = @getNewLabel()

            @manageIteration (=>
                @labelhere backlabel
                cond=if obj.exp2?
                    @calc obj.exp2
                else
                    new Literal true
                @jumpunless cond,endlabel
                @main obj.statement
                @labelhere nextlabel
                if obj.exp3?
                    @calc obj.exp3
                @jump backlabel
                @labelhere endlabel
            ),(=>
                @jump nextlabel
            ),(=>
                @jump endlabel
            )
        else if obj instanceof parser.For_InStatement
            throw new Error "for-in文は対応していません"
        else if obj instanceof parser.For_In_VarStatement
            throw new Error "for-in文は対応していません"
        else if obj instanceof parser.ContinueStatement
            @docontinue obj.identifier?.value
        else if obj instanceof parser.BreakStatement
            @dobreak obj.identifier?.value
        else if obj instanceof parser.ReturnStatement
            f=@funcStack[@funcStack.length-1]
            unless f?
                throw new Error "関数外でreturnは使用できません"
            if obj.exp?
                @result.push new ReturnOperation f,@calc obj.exp
            else
                @result.push new ReturnOperation
        else if obj instanceof parser.WithStatement
            throw new Error "with文は対応していません"
        else if obj instanceof parser.SwitchStatement
            exp=@calc obj.exp
            endlabel=@getNewLabel()
            @manageIteration (=>
                # ラベルを全部つくる
                labels=[]
                default_flg=false
                for arr,i in obj.cases
                    labels[i]=@getNewLabel()
                    if !arr[2]
                        # defaultじゃない
                        @jumpif new Calc2("===",exp,@calc arr[0]),labels[i]
                    else
                        default_flg=true
                # 最後にdefault
                if default_flg
                    for arr,i in obj.cases
                        if arr[2]
                            # default
                            @jump labels[i]
                # 部分部分
                for arr,i in obj.cases
                    @labelhere labels[i]
                    @statements arr[1]
                @labelhere endlabel
            ),null,(=>
                @jump endlabel
            )
        else if obj instanceof parser.LabelledStatement
            if (obj.statement instanceof parser.IterationStatement)||(obj.statement instanceof parser.SwitchStatement)
                @reservedLabelNames.push obj.identifier.name
            @main obj.statement # ここで@reservedLabelNamesは処理されるはずじゃん?
        else if obj instanceof parser.ThrowStatement
            throw new Error "throw文は対応していません"
        else if obj instanceof parser.TryStatement
            throw new Error "try文は対応していません"
        else if obj instanceof parser.DebuggerStatement

        else if obj instanceof parser.FunctionDeclaration
            # 処理済み
        else
            throw new Error "は？ #{obj.tokenize @tma}"
        return
    # parser.Expressionを計算する LiteralかVariableを返す
    # newvmode: 未知の変数に対して新しいVariableを作るか
    calc:(exp,newvmode)->
        first=exp.parts[0]
        if first instanceof parser.Expression
            # Exp!
            if exp.parts.length==1
                # これだけ?
                return @calc first
            second=exp.parts[1]
            if second instanceof parser.PunctuatorToken || second instanceof parser.KeywordToken
                # 演算子式だ!
                if exp.parts.length==2
                    # 後置演算子
                    return @calc1after first,exp.parts[1]
                # 2項演算子
                return @calc2 first,second,exp.parts[2]
            if second instanceof parser.Arguments && exp.parts.length==2
                # 関数呼び出しだ!
                return @callfunc first,second
        else if first instanceof parser.PunctuatorToken
            if exp.parts.length==2
                # 前置演算子だ!
                return @calc1before exp.parts[1],first
            if exp.parts.length==3 && first.value=="(" && exp.parts[2].value==")"
                # 括弧だ!
                return @calc exp.parts[1]
            throw new Error "解釈できません"
        else if exp.parts.length==1
            if first instanceof parser.IdentifierToken
                # 変数だ!
                v = @closure.getVariable first.value
                unless v?
                    if newvmode
                        # 新しいグローバル変数を作ってあげる
                        v=new Variable first.value
                        @closure.addVariable v
                        return v
                    # 関数を探してあげる
                    f=@closure.getFunction first.value
                    if f?
                        return f
                    # 組み込み関数かな?
                    switch first.value
                        when "print"
                            return new Print
                        when "charCode"
                            return new Charcode
                        when "inputChar"
                            return new InputChar
                        when "inputNumber"
                            return new InputNumber
                        when "codeToString"
                            return new CodeToString
                    throw new Error "Undefined variable #{first.value}"
                return v
            else if first instanceof parser.RegExpLiteralToken
                throw new Error "正規表現リテラルは使用できません"
            else if first instanceof parser.StringLiteralToken
                res=first.value.match /^[\"\'](.*)[\"\']$/
                unless res?
                    throw new Error "えっ文字列リテラルじゃないの #{first.value}"
                lstr=res[1]
                # エスケープを変換
                table=
                    "\\b":"\b"
                    "\\f":"\f"
                    "\\r":"\r"
                    "\\n":"\n"
                    "\\t":"\t"
                    "\\v":"\v"
                    "\\'":"'"
                    "\\\"":"\""
                    "\\\\":"\\"
                for key,val of table
                    lstr=lstr.replace key,val
                lstr=lstr.replace "\\([0-7]{1,3})",(all,num8)->String.fromCharCode parseInt num8,8
                lstr=lstr.replace "\\x([0-9a-fA-F]{2})",(all,num16)->String.fromCharCode parseInt num16,16
                lstr=lstr.replace "\\u([0-9a-fA-F]{4})",(all,num16)->String.fromCharCode parseInt num16,16
                return new Literal lstr
            else if first instanceof parser.LiteralToken
                lit=if first.value in ["true","false"]
                    new Literal (if first.value=="true" then true else false)
                else if first.value in ["null","undefined"]
                    throw new Error "null,undefinedは使用できません"
                else
                    new Literal parseInt first.value
                return lit
        else
            throw new Error "は？？"
    # 前置演算子のアレ
    calc1before:(exp,punc)->
        v=@calc exp
        punc=punc.value || punc
        switch punc
            when "++","--"
                unless v instanceof Variable && v.name
                    # ちゃんとした変数じゃないといや
                    throw new Error "代入できません"
                ca=if punc=="++"
                    new Calc2 "+",v,new Literal 1
                else
                    new Calc2 "-",v,new Literal 1
                @substitute v,ca
                return v
            when "+"
                return @tonumber v
            when "-"
                nu=@tonumber v
                return new Calc2 "*",nu,new Literal -1
            when "!"
                bu=@toboolean v
                return new Calc1 "!",bu
            else
                throw new Error "演算子#{punc}は使用できません。"
    calc1after:(exp,punc)->
        v=@calc exp
        punc=punc.value || punc
        switch punc
            when "++","--"
                unless v instanceof Variable && v.name
                    # ちゃんとした変数じゃないといや
                    throw new Error "代入できません"
                v2=@getTempVariable()
                @substitute v2,v
                ca=if punc=="++"
                    new Calc2 "+",v,new Literal 1
                else
                    new Calc2 "-",v,new Literal 1
                @substitute v,ca
                return v2
            else
                throw new Error "演算子#{punc}は使用できません。"
    calc2:(mae,punc,ato)->
        punc=punc.value || punc
        switch punc
            when ","
                @calc mae
                return @calc ato
            when "+=","-=","*=","/=","%="
                v=@calc mae
                unless v instanceof Variable && v.name
                    throw new Error "代入できません。"
                a=@calc ato
                @substitute v,new Calc2 punc[0],v,a
                return v
            when "="
                v=@calc mae,true
                unless v instanceof Variable && v.name
                    throw new Error "代入できません。"
                a=@calc ato
                @substitute v,a
                return v
            when "!=","!==","==","===","+","-","*","/","%",">",">=","<=","<","|","&","^","||","&&"
                # ふつうの
                mae=@calc mae
                ato=@calc ato
                res=@getTempVariable()
                @substitute res,new Calc2 punc,mae,ato
                return res
            else
                throw new Error "演算子#{punc}は使用できません。"
    # 関数呼び出し
    callfunc:(exp,args)->
        f=@calc exp
        unless f instanceof Func
            throw new Error "関数ではありません。"
        new Call f,((@calc e) for e in args)
    # 関数を作る（コード展開はしない）
    makeFunction:(func)->
        #func: FunctionDeclaration
        res=new Func func.name,func.paramlist,func.functionbody
        # 独自拡張
        switch func.returnType
            when "number"
                res.type=res.TYPE_NUMBER
            when "string"
                res.type=res.TYPE_STRING
            when "boolean"
                res.type=res.TYPE_BOOLEAN
        res
    codeFunction:(func)->
        #func: Func
        # 新しいクロージャを展開
        @closure=@closure.getChild()
        # 変数を展開
        func.start.vars=[]
        for pi in func.paramlist
            #pi: parser.Identifier
            v=@getLocalVariable pi.value
            func.start.vars.push v
        @funcStack.push func
        # 開始点をアレする
        @result.push func.start
        # 中身を展開する
        @statements func.functionbody,false
        # いちおうreturnをおいておく
        @result.push new ReturnOperation func
        @funcStack.pop()
        # クロージャを破棄する
        @closure=@closure.parent
    # 数値に変換する
    tonumber:(val)->
        if val instanceof Literal
            switch val.type
                when val.TYPE_NUMBER
                    return val
                when val.TYPE_STRING
                    re=parseInt val.value
                    if isNaN re
                        throw new Error JSON.stringify(val.value)+"は数値に変換できません。"
                    return new Literal re
                when val.TYPE_BOOLEAN
                    return new Literal +val.value
        else
            return new Calc1 "to_number",val
        return
    # 真偽値に変換する
    toboolean:(val)->
        if val instanceof Literal
            switch val.type
                when val.TYPE_NUMBER,val.TYPE_STRING
                    return new Literal !!val.value
                when val.TYPE_BOOLEAN
                    return val
        else
            return new Calc1 "to_boolean",val
        return
    # 代入文をつくる
    substitute:(v,value)->
        if value instanceof Variable || value instanceof Literal || value instanceof Calc
            v.type=value.type
        @result.push new SubstituteOperation v,value
    # jump文をつくる
    jump:(label)->
        @result.push new JumpOperation label
    # jumpif文をつくる
    jumpif:(cond,label)->
        @result.push new JumpifOperation cond,label
    # jumpunless文をつくる
    jumpunless:(cond,label)->
        @result.push new JumpunlessOperation cond,label
    # ここにラベルをつくろう
    labelhere:(label)->
        @result.push label
    # ループをアレする
    manageIteration:(main,cont,br)->
        o=new IterationManager main,cont,br,@reservedLabelNames
        @reservedLabelNames=[]
        @iterationStack.push o
        main()
        @iterationStack.pop()
    # continue文の処理
    docontinue:(labelName)->
        flag=false
        for it in @iterationStack by -1
            if !labelName || (labelName in it.labelNames)
                # これだ!
                if it.cont?
                    flag=true
                    it.cont()
                    break
        unless flag
            # なかった
            throw new Error "ループ外でcontinueは使用できません。"
    # break文
    dobreak:(labelName)->
        flag=false
        for it in @iterationStack by -1
            if !labelName || (labelName in it.labelNames)
                # これだ!
                if it.br?
                    flag=true
                    it.br()
                    break
        unless flag
            throw new Error "ループ外でbreakは使用できません。"
    # ローカル変数をつくる
    getLocalVariable:(name)->
        v=@closure.getLocalVariable name
        if v?
            return v
        v=new Variable name
        @closure.addLocalVariable v
        v
    # 一時変数をつくる
    getTempVariable:->
        v=new Variable null
        @closure.addLocalVariable v
        v
    # 新しいラベル
    getNewLabel:->
        @closure.getNewLabel()
class IterationManager
    constructor:(@main,@cont,@br,@labelNames)->
# 中間言語的なやつ
class Operation

# ラベル
class Label extends Operation
    constructor:(@number)->
# 代入文
class SubstituteOperation extends Operation
    # value: Calc or Literal or Variable
    constructor:(@v,@value)->
# jump文
class JumpOperation extends Operation
    constructor:(@label)->
# Jumpif文
class JumpifOperation extends Operation
    constructor:(@cond,@label)->
class JumpunlessOperation extends Operation
    constructor:(@cond,@label)->
# return文
class ReturnOperation extends Operation
    constructor:(@func,@returnvalue)->
# 終了文
class End extends Operation
# 変数
class Variable
    # タイプ定数
    TYPE_NUMBER:1
    TYPE_STRING:2
    TYPE_BOOLEAN:3
    TYPE_UNKNOWN:4    # よくわからない
    constructor:(@name)->   # name:string?
        @type=null
        # ws/compile によってsize（メモリサイズ）が付加されるかも
# リテラル
class Literal
    TYPE_NUMBER:1
    TYPE_STRING:2
    TYPE_BOOLEAN:3
    constructor:(@value)->  # value:string
        @type=null
        switch typeof @value
            when "string"
                @type=@TYPE_STRING
            when "number"
                @type=@TYPE_NUMBER
            when "boolean"
                @type=@TYPE_BOOLEAN
# 計算とその結果
class Calc
    TYPE_NUMBER:1
    TYPE_STRING:2
    TYPE_BOOLEAN:3
    TYPE_UNKNOWN:4
    constructor:->
        @type=null

class Calc1 extends Calc
    constructor:(@op,@value)->
        @type=null
        switch @op
            when "to_number"
                @type=@TYPE_NUMBER
            when "to_boolean","!"
                @type=@TYPE_BOOLEAN
            when "to_string"
                @type=@TYPE_STRING
class Calc2 extends Calc
    #punc:string, val1,val2: Variable or Literal
    constructor:(@punc,@val1,@val2)->
        # タイプをきめる
        @type=null
        switch @punc
            when "+"
                if val1.type==val1.TYPE_STRING || val2.type==val2.TYPE_STRING
                    @type=@TYPE_STRING
                else
                    @type=@TYPE_NUMBER
            when "-","*","/","%"
                @type=@TYPE_NUMBER
            when "!=","!==","==","===",">",">=","<=","<","||","&&"
               @type=@TYPE_BOOLEAN
# 関数
class Func
    TYPE_NUMBER:1
    TYPE_STRING:2
    TYPE_BOOLEAN:3
    TYPE_UNKNOWN:4
    constructor:(@name,@paramlist,@functionbody)->
        # 開始場所を作っておく
        @type=null
        @start=new FunctionStart @
        #ws/compileによってlabelが付加されるかも
class FunctionStart extends Operation
    constructor:(@func)->
        @vars=[]    #Variable
# 関数呼び出し
class Call extends Calc
    TYPE_NUMBER:1
    TYPE_STRING:2
    TYPE_BOOLEAN:3
    TYPE_UNKNOWN:4    # よくわからない
    constructor:(@func,@args)->   #func:Func; args: calcの返り値的な
        if @func.type?
            @type=@func.type

# 組み込み関数
class NativeFunc extends Func
class Print extends NativeFunc
    constructor:->
        super "print",[],null
        @type=@TYPE_NUMBER
class Charcode extends NativeFunc
    constructor:->
        super "charCode",[],null
        @type=@TYPE_NUMBER
class InputChar extends NativeFunc
    constructor:->
        super "inputChar",[],null
        @type=@TYPE_NUMBER
class InputNumber extends NativeFunc
    constructor:->
        super "inputNumber",[],null
        @type=@TYPE_NUMBER
class CodeToString extends NativeFunc
    constructor:->
        super "codeToString",[],null
        @type=@TYPE_STRING


# エクスポート
exports.Compiler=Compiler
exports.Operation=Operation
exports.Label=Label
exports.SubstituteOperation=SubstituteOperation
exports.JumpOperation=JumpOperation
exports.JumpifOperation=JumpifOperation
exports.JumpunlessOperation=JumpunlessOperation
exports.ReturnOperation=ReturnOperation
exports.End=End
exports.Variable=Variable
exports.Literal=Literal
exports.Calc=Calc
exports.Calc1=Calc1
exports.Calc2=Calc2
exports.Func=Func
exports.FunctionStart=FunctionStart
exports.Call=Call

exports.NativeFunc=NativeFunc
exports.Print=Print
exports.Charcode=Charcode
exports.InputChar=InputChar
exports.InputNumber=InputNumber
exports.CodeToString=CodeToString
