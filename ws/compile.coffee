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
            #pos=@allocHeap op.v
            @calc op.value,op.v
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
                # 関数の型をアレする
                if op.returnvalue.type?
                    unless op.func.type?
                        # いろいろいろ
                        op.func.type=op.returnvalue.type
                    else if op.returnvalue.type!=op.func.type
                        # あれっ
                        op.func.type=op.func.TYPE_UNKNOWN
            else
                # ダミー
                @result.push new wo.stack.Push 0
            # 戻る
            @result.push new wo.flow.Return
        else if op instanceof idtm.End
            @result.push new wo.flow.End
        else if op instanceof idtm.FunctionStart
            lb=@getLabel op.func
            #変数に入れる（再帰のときに問題ありか?）
            @result.push new wo.flow.Label lb
    onstack:(obj)->
        if obj.type? && obj.type==obj.TYPE_STRING
            # 文字列の場合はヒープ座標をのせるのだが・・・?
            if obj instanceof idtm.Variable
                @result.push new wo.stack.Push @allocHeap obj
                return
            else
                # それ以外の場合はいったんいれる
                tmpv=new idtm.Variable
                tmpv.type=tmpv.TYPE_STRING
                @calc obj,tmpv
                @result.push new wo.stack.Push @allocHeap tmpv
                return
        # ほかはcalcにまかせる
        @calc obj,null
    # 計算して指定された変数に入れる
    calc:(obj,v)->  #v: ない場合はスタックに積む
        # Variable,Literal,Calc
        if obj instanceof idtm.Variable
            # 文字列の場合はヒープ座標を積んでおこう
            pos=@allocHeap obj
            unless obj.type? && obj.type==obj.TYPE_STRING
                # 文字列以外: ふつうに
                @result.push new wo.stack.Push pos
                @result.push new wo.heap.Retrieve
            else
                unless v?
                    # あれっ
                    @onstack obj
                    return
                newpos=@allocHeap v
                # 文字列: コピーして変数に入れる
                # 位置
                @result.push new wo.stack.Push 0
                lb=@getLabel()
                endlb=@getLabel()
                @result.push new wo.flow.Label lb
                # スタック状況: * [i]
                # 位置をコピー
                @result.push new wo.stack.Duplicate
                @result.push new wo.stack.Push pos
                @result.push new wo.arithmetic.Add
                # スタック状況: * [i] [oldPos+i]
                # つぎのヒープ位置
                @result.push new wo.heap.Retrieve
                @result.push new wo.stack.Duplicate
                # スタック状況: * [i] [i番目の文字] [i番目の文字]
                # 位置をコピー
                @result.push new wo.stack.Copy 2
                @result.push new wo.stack.Push newpos
                @result.push new wo.arithmetic.Add
                # スタック状況: * [i] [i番目の文字] [i番目の文字] [newPos+i]
                @result.push new wo.stack.Swap
                @result.push new wo.heap.Store
                # スタック状況: * [i] [i番目の文字]
                @result.push new wo.flow.JumpZero endlb
                # 次の位置へ
                @result.push new wo.stack.Push 1
                @result.push new wo.arithmetic.Add
                # スタック状況: * [i+1]
                @result.push new wo.flow.Jump lb
                # 後始末
                @result.push new wo.flow.Label endlb
                # スタック状況: * [i]
                @result.push new wo.stack.Discard
                return
        else if obj instanceof idtm.Literal
            if obj.type==obj.TYPE_STRING
                unless v?
                    # あれっ
                    @onstack obj
                    return
                # UTF-8コードに分割
                alloctets=[]
                i=0
                idx=0
                str=obj.value
                # UTF-8に変換
                for i in [0...(str.length)]
                    code=str.charCodeAt i
                    # UTF-8でバイト列に分解する
                    octets=if code<0x80
                        [code]
                    else if code<0x800
                        [0xC0 | ((code>>>6)&0x1F),0x80 | (code&0x3F)]
                    else if code<0xD7FF || 0xE000<=code<0x10000
                        # 3バイト
                        [0xE0 | ((code>>>12)&0x0F),0x80 | ((code>>>6)&0x3F),0x80 | (code&0x3F)]
                    else if code<=0xD800
                        ato=obj.value.charCodeAt i+1
                        uuuuu=((code>>>6)&0x0F)+1
                        [0xF0 | (uuuuu>>2),0x80 | ((uuuuu&3)<<4) | ((code>>2)&0x0F),0x80 | ((code&3)<<4) | ((ato>>6)&0x0F),0x80 | (ato&0x3F)]
                    else
                        # サロゲートペア1つ目はさっき処理したので放置
                        []
                    for c in octets
                        alloctets.push c
                        idx++
                # 最後に終了コード
                alloctets.push 0
                pos=@allocHeap v
                for c,idx in alloctets
                    @result.push new wo.stack.Push pos+idx
                    @result.push new wo.stack.Push c
                    @result.push new wo.heap.Store

                return
            else
                # その他はふつうに入れる
                @result.push new wo.stack.Push +obj.value
        else if obj instanceof idtm.Calc
            if obj instanceof idtm.Calc1
                switch obj.op
                    when "to_number"
                        # 何もしなくていいんじゃない?
                        if obj.value.type && obj.value.type==obj.value.TYPE_STRING
                            throw new Error "文字列を数値に変換できません"
                        @calc obj.value,v
                    when "to_boolean","!"
                        # 0か1に変換しておこう
                        if obj.value.type && obj.value.type==obj.value.TYPE_STRING
                            # 文字列の場合空文字列かどうか判定する
                            # だめなとき用の0
                            @result.push new wo.stack.Push 0
                            # 文字列の場合はヒープ座標がおかれる
                            @onstack obj.value
                            # 1バイト目を取得
                            @result.push new wo.heap.Retrieve
                            # 0だったらだめ
                            tmplb=@getLabel()
                            @result.push new wo.flow.JumpZero tmplb
                            # 1にする
                            @result.push new wo.stack.Discard
                            @result.push new wo.stack.Push 1
                            @result.push new wo.flow.Label tmplb
                        else
                            if obj.value.type != obj.value.TYPE_BOOLEAN
                                tmplb=@getLabel()
                                # だめなとき用の0
                                @result.push new wo.stack.Push 0
                                # 0のときはとぶ
                                @onstack obj.value
                                @result.push new wo.flow.JumpZero tmplb
                                # 1にする
                                @result.push new wo.stack.Discard
                                @result.push new wo.stack.Push 1
                                @result.push new wo.flow.Label tmplb
                            else
                                # おくだけ
                                @onstack obj.value
                        if obj.op=="!"
                            # 反転の場合は逆にする
                            @result.push new wo.stack.Push 1
                            @result.push new wo.stack.Swap
                            @result.push new wo.arithmetic.Subtract
                    when "to_string"
                        # 文字列に直す
                        if obj.value.type? && obj.value.type==obj.value.TYPE_STRING
                            # コピーするだけ
                            @calc obj.value,v
                            return
                        unless v?
                            # あれっ
                            @onstack obj
                            return
                        pos=@allocHeap v
                        @result.push new wo.stack.Push 0
                        @onstack obj.value
                        if obj.value.type? && obj.value.type==obj.value.TYPE_BOOLEAN
                            # trueかfalse
                            # スタック状況: * [0] [val]
                            lb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.flow.JumpZero lb
                            # trueをのせる
                            @result.push new wo.stack.Push 0x65
                            @result.push new wo.stack.Push 0x75
                            @result.push new wo.stack.Push 0x72
                            @result.push new wo.stack.Push 0x74
                            # スタック状況: * [0] "e" "u" "r" "t"
                            @result.push new wo.flow.Jump endlb
                            @result.push new wo.flow.Label lb
                            @result.push new wo.stack.Push 0x65
                            @result.push new wo.stack.Push 0x73
                            @result.push new wo.stack.Push 0x6C
                            @result.push new wo.stack.Push 0x61
                            @result.push new wo.stack.Push 0x66
                            @result.push new wo.flow.Label endlb
                            # スタック状況: * [0] "e" "s" "l" "a" "f"
                        else
                            # 数値だろう
                            lb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.flow.Label lb
                            # スタック状況:* [0] ... [val]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Push 10
                            @result.push new wo.arithmetic.Modulo
                            # スタック状況:* [0] ... [val] [val%10]
                            # 一番下の位
                            @result.push new wo.stack.Push 0x30 # 0
                            @result.push new wo.arithmetic.Add
                            @result.push new wo.stack.Swap
                            # スタック状況:* [0] ... "(val%10)" [val]
                            @result.push new wo.stack.Push 10
                            @result.push new wo.arithmetic.Divide
                            # スタック状況:* [0] ... "(val%10)" [val/10]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.flow.JumpZero endlb
                            @result.push new wo.flow.Jump lb
                            @result.push new wo.flow.Label endlb
                            # もう0になった
                            # スタック状況:* [0] ... "(val%10)" [0]
                            @result.push new wo.stack.Discard
                        # 変換後の文字列をスタックに積み終わった
                        @result.push new wo.stack.Push 0
                        lb2=@getLabel()
                        endlb2=@getLabel()
                        @result.push new wo.flow.Label lb2
                        # スタック状況:* [0] ... "*" [i]
                        @result.push new wo.stack.Duplicate
                        @result.push new wo.stack.Push pos
                        @result.push new wo.arithmetic.Add
                        @result.push new wo.stack.Copy 2
                        # スタック状況:* [0] ... "*" [i] [pos+i] "*"
                        @result.push new wo.heap.Store
                        @result.push new wo.stack.Swap
                        # スタック状況:* [0] ... [i] "*"
                        @result.push new wo.flow.JumpZero endlb2
                        @result.push new wo.stack.Push 1
                        @result.push new wo.arithmetic.Add
                        # スタック状況:* [0] ... [i+1]
                        @result.push new wo.flow.Jump lb2
                        # 終了
                        @result.push new wo.flow.Label endlb2
                        # スタック状況:* [i] 
                        @result.push new wo.stack.Discard
                        return

            else if obj instanceof idtm.Calc2
                switch obj.punc
                    when "+","-","*","/","%"
                        if obj.type? && obj.type==obj.TYPE_STRING
                            # 文字列の計算だ
                            if obj.punc!="+"
                                throw new Error "文字列の計算は加算以外できません"
                            #unless obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING && obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                                #throw new Error "文字列とそれ以外の加算には対応していません"


                            unless v?
                                @onstack obj
                                return
                            #--- まず前のをvにコピーしていく
                            newpos=@allocHeap v
                            # まず前のやつの位置を入れておく
                            if obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING
                                # 文字列
                                @onstack obj.val1
                            else
                                # 文字列に変換
                                @onstack new idtm.Calc1 "to_string",obj.val1
                            # 位置
                            @result.push new wo.stack.Push 0
                            lb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.flow.Label lb
                            # スタック状況: * [val1Heap] [i]
                            # 位置をコピー
                            @result.push new wo.stack.Duplicate
                            # スタック状況: * [val1Heap] [i] [i]
                            @result.push new wo.stack.Copy 2
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val1Heap] [i] [val1Heap+i]
                            # つぎのヒープ位置
                            @result.push new wo.heap.Retrieve
                            @result.push new wo.stack.Duplicate
                            # スタック状況: * [val1Heap] [i] [i番目の文字] [i番目の文字]
                            @result.push new wo.stack.Copy 2
                            @result.push new wo.stack.Push newpos
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val1Heap] [i] [i番目の文字] [i番目の文字]  [newHeap+i]
                            @result.push new wo.stack.Swap
                            @result.push new wo.heap.Store
                            # 終端コードきたらコピーおわり
                            # スタック状況: * [val1Heap] [i] [i番目の文字]
                            @result.push new wo.flow.JumpZero endlb
                            # 次の位置へ
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val1Heap] [i+1]
                            @result.push new wo.flow.Jump lb
                            @result.push new wo.flow.Label endlb
                            # スタック状況: * [val1Heap] [i]
                            # ここからあたらしいやつを追加していく
                            @result.push new wo.stack.Slide 1
                            # スタック状況: * [i]
                            # 次のやつの位置をおく
                            if obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                                # 文字列
                                @onstack obj.val2
                            else
                                # 文字列に変換
                                @onstack new idtm.Calc1 "to_string",obj.val2
                            @result.push new wo.stack.Swap
                            lb2=@getLabel()
                            endlb2=@getLabel()
                            @result.push new wo.stack.Push 0
                            @result.push new wo.flow.Label lb2
                            # スタック状況: * [val2Heap] [i] [j] i:val1の分の長さ j:val2の位置

                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Copy 3
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val2Heap] [i] [j] [val2Heap+j]
                            @result.push new wo.heap.Retrieve
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Copy 2
                            # スタック状況: * [val2Heap] [i] [j] [j番目の文字] [j番目の文字] [j]
                            @result.push new wo.stack.Push newpos
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val2Heap] [i] [j] [j番目の文字] [j番目の文字] [newHeap+j]
                            @result.push new wo.stack.Copy 4
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val2Heap] [i] [j] [j番目の文字] [j番目の文字] [newHeap+i+j]
                            @result.push new wo.stack.Swap
                            @result.push new wo.heap.Store
                            # スタック状況: * [val2Heap] [i] [j] [j番目の文字]
                            @result.push new wo.flow.JumpZero endlb2
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [val2Heap] [i] [j+1]
                            @result.push new wo.flow.Jump lb2
                            @result.push new wo.flow.Label endlb2
                            # スタック状況: * [val2Heap] [i] [j] 
                            @result.push new wo.stack.Slide 2
                            @result.push new wo.stack.Discard
                            # スタック状況: *
                            return
                        else
                            # 文字列以外はすなおにやる
                            @onstack obj.val1
                            @onstack obj.val2
                            @result.push switch obj.punc
                                when "+" then new wo.arithmetic.Add
                                when "-" then new wo.arithmetic.Subtract
                                when "*" then new wo.arithmetic.Multiply
                                when "/" then new wo.arithmetic.Divide
                                when "%" then new wo.arithmetic.Modulo
                    when "!=","!=="
                        if obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING || obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                            #文字列比較の場合はアレする
                            @call new idtm.Calc1("!",new idtm.Calc2 "==",obj.val1,obj.val2),v
                            return
                        # 他はひいてbool化する
                        @onstack new idtm.Calc1 "to_boolean",new idtm.Calc2 "-",obj.val1,obj.val2
                    when "==","==="
                        if obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING && obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                            # 両方文字列: 1文字ずつ比較
                            lb=@getLabel()
                            lb2=@getLabel()
                            lb3=@getLabel()
                            endlb=@getLabel()
                            # さいしょは1
                            @result.push new wo.stack.Push 1
                            @onstack obj.val1
                            @onstack obj.val2
                            @result.push new wo.stack.Push 0 # 現在の比較位置
                            @result.push new wo.flow.Label lb
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Copy 3
                            @result.push new wo.stack.Add
                            @result.push new wo.heap.Retrieve
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i] [val1のi番目]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Copy 2
                            @result.push new wo.stack.Copy 4
                            @result.push new wo.stack.Add
                            @result.push new wo.heap.Retrieve
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i] [val1のi番目] [val1のi番目] [val2のi番目]
                            @result.push new wo.arithmetic.Subtract
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i] [val1のi番目] [i番目の差]
                            @result.push new wo.flow.JumpZero lb2
                            # 0じゃなかったとき: 違う
                            @result.push new wo.stack.Slide 4
                            @result.push new wo.stack.Discard
                            @result.push new wo.stack.Push 0
                            # スタック状況: * [0]
                            @result.push new wo.flow.Jump endlb
                            @result.push new wo.flow.Label lb2
                            # 0だったとき
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i] [val1のi番目]
                            # val1のi番目が0だったら終了 そうでなかったら次へ
                            @result.push new wo.stack.JumpZero lb3
                            # 次へ進む
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i+1]
                            @result.push new wo.flow.Jump lb
                            @result.push new wo.flow.Label lb3
                            # スタック状況: * [1] [val1Heap] [val2Heap] [i]
                            # ぶじ成功で終了
                            @result.push new wo.flow.Slide 2
                            @result.push new wo.stack.Discard
                            # スタック状況: * [1]
                        else if obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING || obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                            # 無理
                            throw new Error "文字列とそれ以外の等値比較はできません。"
                        else
                            # ひいてbool化する
                            @onstack new idtm.Calc1 "!",(new idtm.Calc2 "-",obj.val1,obj.val2)
                    when ">",">=","<","<="
                        # ひきざんしたりする
                        if obj.val1.type? && obj.val1.type==obj.val1.TYPE_STRING || obj.val2.type? && obj.val2.type==obj.val2.TYPE_STRING
                            throw new Error "文字列の比較はできません。"
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
                        # その他はそのままアレする
                        if a.type? && (a.type in [a.TYPE_STRING,a.TYPE_BOOLEAN])
                            # 掘り進める
                            # 文字列に変換する
                            if a.type==a.TYPE_BOOLEAN
                                @onstack new idtm.Calc1 "to_string",a
                            else
                                @onstack a
                            tmplb=@getLabel()
                            endlb=@getLabel()
                            @result.push new wo.stack.Push 0
                            @result.push new wo.flow.Label tmplb
                            # スタック状況: * [strHeap] [i]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.stack.Copy 2
                            @result.push new wo.arithmetic.Add
                            @result.push new wo.heap.Retrieve
                            # スタック状況: * [strHeap] [i] [i番目の文字]
                            @result.push new wo.stack.Duplicate
                            @result.push new wo.flow.JumpZero endlb
                            @result.push new wo.io.OutputChar
                            @result.push new wo.stack.Push 1
                            @result.push new wo.arithmetic.Add
                            # スタック状況: * [strHeap] [i+1]
                            @result.push new wo.flow.Jump tmplb
                            @result.push new wo.flow.Label endlb
                            # スタック状況: * [strHeap] [i] [0]
                            # Duplicateでひとつ残ったNULL文字は返り値としてとっておく
                            @result.push new wo.stack.Slide 2
                        else if a instanceof idtm.Variable && a.type==a.TYPE_UNKNOWN
                            # わからない
                            throw new Error "変数#{a.name ? ''}の型を特定できないのでprintできません。"
                        else
                            @onstack a
                            # 素直に出力
                            @result.push new wo.io.OutputNumber
                            @result.push new wo.stack.Push 0
                    else if obj.func instanceof idtm.Charcode
                        # 文字コード
                        a=obj.args[0]
                        unless a?
                            throw new Error "charcodeの引数がありません。"
                        b=obj.args[1]
                        unless b?
                            b=new idtm.Literal 0
                        @onstack a
                        if a.type? && a.type==a.TYPE_STRING
                            # 文字列だ
                            @onstack b
                            @result.push new wo.arithmetic.Add
                            @result.push new wo.heap.Retrieve
                    else if obj.func instanceof idtm.InputChar
                        # 文字ひとつ入力
                        if v?
                            # これに入れよう
                            @result.push new wo.stack.Push @allocHeap v
                            @result.push new wo.io.ReadChar
                            return
                        else
                            # 入力用ヒープ
                            tmpv=new idtm.Variable
                            pos=@allocHeap tmpv
                            @result.push new wo.stack.Push pos
                            @result.push new wo.io.ReadChar
                            @result.push new wo.stack.Push pos
                            @result.push new wo.heap.Retrieve
                    else if obj.func instanceof idtm.InputNumber
                        if v?
                            # これに入れよう
                            @result.push new wo.stack.Push @allocHeap v
                            @result.push new wo.io.ReadChar
                            return
                        else
                            tmpv=new idtm.Variable
                            pos=@allocHeap tmpv
                            @result.push new wo.stack.Push pos
                            @result.push new wo.io.ReadNumber
                            @result.push new wo.stack.Push pos
                            @result.push new wo.heap.Retrieve
                    else if obj.func instanceof idtm.CodeToString
                        # 文字コードをアレする
                        unless v?
                            #えっ
                            @onstack obj
                            return
                        a=obj.args[0]
                        unless a?
                            throw new Error "charcodeの引数がありません。"
                        if a.type? && a.type!=a.TYPE_NUMBER
                            throw new Error "codeToStringは数値を引数に呼び出す必要があります。"
                        pos=@allocHeap v
                        @result.push new wo.stack.Push pos
                        @onstack a
                        @result.push new wo.heap.Store
                        @result.push new wo.stack.Push pos+1
                        @result.push new wo.stack.Push 0
                        @result.push new wo.heap.Store
                        return
                    else
                        throw new Error "ん？"

                else
                    lb=@getLabel obj.func
                    args=obj.args
                    for va,i in obj.func.start.vars
                        unless args[i]?
                            #えっ
                            throw new Error "引数が足りません"
                        @calc args[i],va
                        # 変数の型
                        if args[i].type?
                            if va.type?
                                if args[i].type!=va.type
                                    # あーあ
                                    va.type=v.TYPE_UNKNOWN
                            else
                                va.type=args[i].type

                    @result.push new wo.flow.Call lb
                    if v? && obj.func.type? && obj.func.type==obj.func.TYPE_STRING
                        # 位置をたよりにコピー
                        newpos=@allocHeap v
                        # 位置
                        @result.push new wo.stack.Push 0
                        lb2=@getLabel()
                        endlb2=@getLabel()
                        @result.push new wo.flow.Label lb2
                        # スタック状況: * [oldPos] [i]
                        # 位置をコピー
                        @result.push new wo.stack.Duplicate
                        @result.push new wo.stack.Copy 2
                        @result.push new wo.arithmetic.Add
                        # スタック状況: * [oldPos] [i] [oldPos+i]
                        # つぎのヒープ位置
                        @result.push new wo.heap.Retrieve
                        @result.push new wo.stack.Duplicate
                        # スタック状況: * [oldPos] [i] [i番目の文字] [i番目の文字]
                        # 位置をコピー
                        @result.push new wo.stack.Copy 2
                        @result.push new wo.stack.Push newpos
                        @result.push new wo.arithmetic.Add
                        # スタック状況: * [oldPos] [i] [i番目の文字] [i番目の文字] [newPos+i]
                        @result.push new wo.stack.Swap
                        @result.push new wo.heap.Store
                        # スタック状況: * [oldPos] [i] [i番目の文字]
                        @result.push new wo.flow.JumpZero endlb2
                        # 次の位置へ
                        @result.push new wo.stack.Push 1
                        @result.push new wo.arithmetic.Add
                        # スタック状況: * [oldPos] [i+1]
                        @result.push new wo.flow.Jump lb2
                        # 後始末
                        @result.push new wo.flow.Label endlb2
                        # スタック状況: * [oldPos] [i]
                        @result.push new wo.stack.Discard
                        @result.push new wo.stack.Discard
                        return
        # スタックに載っているのでvがあれば最後にいれる
        if v?
            pos=@allocHeap v
            @result.push new wo.stack.Push pos
            @result.push new wo.stack.Swap
            @result.push new wo.heap.Store

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
        i=0
        #while i<len
        while true
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
