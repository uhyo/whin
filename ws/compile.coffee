idtm=require '../js/idtm'
wo=require './operations'

class Compiler
    constructor:->
        @result=[]
        # もともとあるラベルのやつ
        @myLabelnumber=0    # 自分が発行したやつ
        @labels=[]  # number: idtm.Labelのnumber

        # ヒープ管理(Variableをいれる)
        @heap=[]
    compile:(ops)->   #[idtm.Operation]
        for op in ops
            @maincalc op
        @result
    maincalc:(op)->
        # オペレーションをひとつ計算してみる
        if op instanceof idtm.Label
            # ラベルだああああああ
            @result.push new wo.flow.Label @getLabel op
        else if op instanceof idtm.SubstituteOperation
            pos=@allocHeap op.v
            @result.push new wo.stack.Push pos
            # スタックの一番上におくぞーーーーーーーーー
            @onstack op.value
            if op.v.type? && op.v.type==op.v.TYPE_STRING
                # ひとつずつコピーする
                throw new Error "未実装:文字列のコピー"
            else
                # ヒープに入れる
                @result.push new wo.heap.Store
        else if op instanceof idtm.JumpOperation
            lb=@getLabel op.label
            @result.push new wo.flow.Jump lb
        else if op instanceof idtm.JumpifOperation || op instanceof idtm.JumpunlessOperation
            # 一段深く場合分ける
            constr=null
            neg=false   # 逆
            ###
            if op.cond instanceof idtm.Calc2
                switch op.cond.punc
                    when "+","-","*","/","%"
                        @onstack op.cond
                        constr=wo.flow.JumpZero
                        neg=!neg
                    when "!=","!=="
                        @onstack op.cond.val1
                        @onstack op.cond.val2
                        # 引き算して違えばいい
                        @result.push new wo.arithmetic.Subtract
                        constr=wo.flow.JumpZero
                        neg=!neg
                    when "==","==="
                        # 同じならいい
                        @onstack op.cond.val1
                        @onstack op.cond.val2
                        # 引き算して違えばいい
                        @result.push new wo.arithmetic.Subtract
                        constr=wo.flow.JumpZero
                    when ">",">="
                        # 小から大をひいてみる
                        @onstack op.cond.val2
                        @onstack op.cond.val1
                        @result.push new wo.arithmetic.Subtract
                        if op.cond.punc==">="
                            # 0も許すので1ひく
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Subtract
                        constr=wo.flow.JumpNegative
                    when "<","<="
                        # 小から大をひいてみる
                        @onstack op.cond.val1
                        @onstack op.cond.val2
                        @result.push new wo.arithmetic.Subtract
                        if op.cond.punc=="<="
                            # 0も許すので1ひく
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Subtract
                        constr=wo.flow.JumpNegative
                    when "||","&&"
                        @onstack new idtm.Calc1 "to_boolean",op.cond.val1
                        @onstack new idtm.Calc1 "to_boolean",op.cond.val2
                        if op.cond.punc=="||"
                            # 論理和
                            @result.push new wo.arithmetic.Add
                        else
                            # 論理積
                            @result.push new wo.arithmetic.Multiply
                        neg=!neg
                        constr=wo.flow.JumpZero
            else
                #Calc2以外
                @onstack new idtm.Calc1 "to_boolean",op.cond
                constr=wo.flow.JumpZero
            ###
            @onstack new idtm.Calc1 "to_boolean",op.cond
            # 1のとき飛べばいいので逆
            neg=!neg
            constr=wo.flow.JumpZero
            if op instanceof idtm.JumpunlessOperation
                neg=!neg
            # neg: false->ふつうにとぶ true->とばないときとぶ
            if neg
                tmplb=@getLabel()
                @result.push new constr tmplb
                @result.push new wo.flow.Jump @getLabel op.label
                @result.push new wo.flow.Label tmplb
            else
                @result.push new constr @getLabel op.label
        else if op instanceof idtm.ReturnOperation
            if op.returnvalue?
                @onstack op.returnvalue
            else
                # ダミー
                @result.push new wo.stack.Push 0
            # 戻る
            @result.push new wo.flow.Return
        else if op instanceof idtm.End
            @result.push new wo.flow.End
        else if op instanceof idtm.FunctionStart
            lb=@getLabel op.func
            @result.push new wo.flow.Label lb
            #変数に入れる（再帰のときに問題ありか?）
    onstack:(obj)->
        # Variable,Literal,Calc
        if obj instanceof idtm.Variable
            pos=@allocHeap obj
            @result.push new wo.stack.Push pos
            @result.push new wo.heap.Retrieve
        else if obj instanceof idtm.Literal
            if obj.type==obj.TYPE_STRING
                # 文字列は逆にしてのせる
                @result.push new wo.stack.Push 0    # NULL文字
                for i in [0...(obj.value.length)] by -1
                    code=obj.value.charCodeAt i
                    # UTF-8でバイト列に分解する
                    octets=if code<0x80
                        [code]
                    else if code<0x800
                        [0xC0 | ((code>>>6)&0x1F),0x80 | (code&0x3F)]
                    else if code<0xD7FF || 0xE000<=code<0x10000
                        # 3バイト
                        [0xE0 | ((code>>>12)&0x0F),0x80 | ((code>>>6)&0x3F),0x80 | (code&0x3F)]
                    else if 0xDC00<=code
                        # サロゲートペア2つ目
                        mae=obj.value.charCodeAt i-1
                        uuuuu=((mae>>>6)&0x0F)+1
                        [0xF0 | (uuuuu>>2),0x80 | ((uuuuu&3)<<4) | ((mae>>2)&0x0F),0x80 | ((mae&3)<<4) | ((code>>6)&0x0F),0x80 | (code&0x3F)]
                    else
                        # サロゲートペア1つ目はさっき処理したので放置
                        []
                    # やはり逆順にして追加
                    octets.reverse()
                    for code in octets
                        @result.push new wo.stack.Push code
            else
                # その他はふつうにのせる
                @result.push new wo.stack.Push +obj.value
        else if obj instanceof idtm.Calc
            if obj instanceof idtm.Calc1
                switch obj.op
                    when "to_number"
                        # 何もしなくていいんじゃない?
                        @onstack obj.value
                    when "to_boolean","!"
                        # 0か1に変換しておこう
                        @onstack obj.value
                        if obj.value.type != obj.value.TYPE_BOOLEAN
                            tmplb=@getLabel()
                            # 0のときはとぶ
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.flow.JumpZero tmplb
                            # 1にする
                            @result.push new wo.stack.Discard
                            @result.push new wo.stack.Push 1
                            @result.push new wo.flow.Label tmplb
                        if obj.op=="!"
                            # 反転の場合は逆にする
                            @result.push new wo.stack.Push 1
                            @result.push new wo.stack.Swap
                            @result.push new wo.arithmetic.Subtract
            else if obj instanceof idtm.Calc2
                switch obj.punc
                    when "+","-","*","/","%"
                        # 文字列はとりあえず無視?
                        @onstack obj.val1
                        @onstack obj.val2
                        @result.push switch obj.punc
                            when "+" then new wo.arithmetic.Add
                            when "-" then new wo.arithmetic.Subtract
                            when "*" then new wo.arithmetic.Multiply
                            when "/" then new wo.arithmetic.Divide
                            when "%" then new wo.arithmetic.Modulo
                    when "!=","!=="
                        # ひいてbool化する
                        @onstack new idtm.Calc1 "to_boolean",new idtm.Calc2 "-",obj.val1,obj.val2
                    when "==","==="
                        # ひいてbool化する
                        @onstack new idtm.Calc1 "!",(new idtm.Calc2 "-",obj.val1,obj.val2)
                    when ">",">=","<","<="
                        # ひきざんしたりする
                        tmplb=@getLabel()
                        tmpend=@getLabel()
                        switch obj.punc
                            when ">",">="
                                @onstack obj.val2
                                @onstack obj.val1
                                @result.push new wo.arithmetic.Subtract
                                if obj.punc==">="
                                    @result.push new wo.stack.Push 1
                                    @result.push new wo.arithmetic.Subtract
                                @result.push new wo.flow.JumpNegative tmplb
                            when "<","<="
                                @onstack obj.val1
                                @onstack obj.val2
                                @result.push new wo.arithmetic.Subtract
                                if obj.punc=="<="
                                    @result.push new wo.stack.Push 1
                                    @result.push new wo.arithmetic.Subtract
                                @result.push new wo.flow.JumpNegative tmplb
                        # 飛ばなかったとき
                        @result.push new wo.stack.Push 0
                        @result.push new wo.flow.Jump tmpend

                        @result.push new wo.flow.Label tmplb
                        # 飛んだとき
                        @result.push new wo.stack.Push 1
                        @result.push new wo.flow.Label tmpend
                    when "||"
                        @onstack new idtm.Calc1 "to_boolean",obj.val1
                        @onstack new idtm.Calc1 "to_boolean",obj.val2
                        # 論理和
                        @result.push new wo.arithmetic.Add
                        # 2になったら?
                        @result.push new wo.stack.Duplicate
                        @resuht.push new wo.stack.Push 2
                        @result.push new wo.arithmetic.Subtract
                        @result.push new wo.stack.Push 1    # ふつうは0をひくけど2のときは1をひく
                        tmplb=@getLabel()
                        @result.push new wo.flow.JumpZero tmplb
                        # 0になおす
                        @result.push new wo.stack.Discard
                        @resutl.push new wo.stack.Push 0
                    when "&&"
                        @onstack new idtm.Calc1 "to_boolean",obj.val1
                        @onstack new idtm.Calc1 "to_boolean",obj.val2
                        # 論理積
                        @result.push new wo.arithmetic.Multiply
            else if obj instanceof idtm.Call
                # 関数はすべてスタックに戻り値を積む予定だし
                if obj.func instanceof idtm.NativeFunc
                    # ネイティブな動作をする
                    if obj.func instanceof idtm.Print
                        # printする関数だ！
                        a=obj.args[0]
                        unless a?
                            throw new Error "printの引数がありません。"
                        if a instanceof idtm.Calc2
                            if a.type? && a.type==a.TYPE_STRING && a.punc=="+"
                                # 文字列連結だ
                                # 分解する
                                @onstack new idtm.Call new idtm.Print,[a.val1]
                                @onstack new idtm.Call new idtm.Print,[a.val2]
                                @result.push new wo.stack.Discard
                                return
                        # その他はそのままアレする
                        @onstack a
                        if a.type? && a.type==a.TYPE_STRING
                            # 掘り進める
                            tmplb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.flow.Label tmplb
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.flow.JumpZero endlb
                            @result.push new wo.io.OutputChar
                            @result.push new wo.flow.Jump tmplb
                            @result.push new wo.flow.Label endlb
                            # Duplicateでひとつ残ったNULL文字は返り値としてとっておく
                        else
                            # 素直に出力
                            @result.push new wo.io.OutputNumber
                            @result.push new wo.stack.Push 0
                    else if obj.func instanceof idtm.Charcode
                        # 文字コード
                        a=obj.args[0]
                        unless a?
                            throw new Error "charcodeの引数がありません。"
                        @onstack a
                        if a.type? && a.type==a.TYPE_STRING
                            # 文字列だ
                            # 一番上を残して他を取り除く
                            tmpv=new idtm.Variable
                            pos=@allocHeap tmpv
                            @result.push new wo.stack.Push pos
                            @result.push new wo.stack.Swap
                            @result.push new wo.heap.Store
                            # 残りを消す
                            tmplb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.flow.Label tmplb
                            @result.push new wo.flow.JumpZero endlb
                            @result.push new wo.flow.Jump tmplb
                            @result.push new wo.flow.Label endlb
                            # もどす
                            @result.push new wo.stack.Push pos
                            @result.push new wo.heap.Retrieve
                    else if obj.func instanceof idtm.InputChar
                        # 文字ひとつ入力
                        tmpv=new idtm.Variable
                        pos=@allocHeap tmpv
                        @result.push new wo.stack.Push pos
                        @result.push new wo.io.ReadChar
                        @result.push new wo.stack.Push pos
                        @result.push new wo.heap.Retrieve
                    else if obj.func instanceof idtm.InputNumber
                        tmpv=new idtm.Variable
                        pos=@allocHeap tmpv
                        @result.push new wo.stack.Push pos
                        @result.push new wo.io.ReadNumber
                        @result.push new wo.stack.Push pos
                        @result.push new wo.heap.Retrieve
                    else
                        throw new Error "ん？"

                else
                    lb=@getLabel obj.func
                    args=obj.args
                    for v,i in obj.func.start.vars
                        unless args[i]?
                            #えっ
                            throw new Error "引数が足りません"
                        heappos=@allocHeap v
                        @result.push new wo.stack.Push heappos
                        @onstack args[i]
                        @result.push new wo.heap.Store



                    @result.push new wo.flow.Call lb
                    



    getLabel:(lb)->
        thislabel=@myLabelnumber
        if lb instanceof idtm.Label
            if @labels[lb.number]?
                return @labels[lb.number]
            else
                @labels[lb.number]=@numberToLabelstring thislabel
                @myLabelnumber++
                return @labels[lb.number]
        else if lb instanceof idtm.Func
            if lb.label?
                return lb.label
            lb.label=@numberToLabelstring thislabel
            @myLabelnumber++
            return lb.label
        else
            # 新しいのを発行
            @myLabelnumber++
            return @numberToLabelstring thislabel
    allocHeap:(v)->
        # この変数のためのヒープを用意する
        unless v.size?
            # えー
            if v.type==v.TYPE_STRING
                v.size=256
            else
                v.size=1
        heappos=null
        i=0
        len=@heap.length
        while i<len
            va=@heap[i]
            # 既にあった
            if v==va
                return i
            i+= va.size
        while i<len
            va=@heap[i]
            unless va?
                # 穴があった
                # 全て空いているかチェックする
                heappos=i
                for j in [1...(v.size)]
                    if @heap[i+j]?
                        # だめじゃん!
                        heappos=null
                        break
                if heappos?
                    break
            i+= va.size
        unless heappos?
            # 新しいの
            heappos=@heap.length
        @heap[heappos]=v
        return heappos
    numberToLabelstring:(num)->
        # 0以上の数字をラベル用アレに変換
        result=""
        while num>0
            if num%2==1
                result="\t"+result
                num--
            else
                result=" "+result
            num/=2
        if result==""
            # num?
            result=" "
        result


exports.Compiler=Compiler
