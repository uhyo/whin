parser=require '../js/parser'
operations=require '../ws/operations'
class WSManager extends parser.TokenizeManager
    just:->new Just
    indent:(tokenlist)->
        ret=new tokenlist.constructor
        flg=true
        for t in tokenlist
            if flg
                flg=false
                if t instanceof Indent
                    ret.push new Indent t.level+1
                else
                    ret.push new Indent 1
                    ret.push t
            else
                ret.push t
            if t instanceof NewLine
                flg=true
        ret
    newline:->new NewLine
    chomp:(tokenlist)->
        for t in tokenlist by -1
            if t instanceof NewLine
                tokenlist.pop()
            else
                break
        tokenlist

#tokens
class WSToken
    likeIdentifier:->false

class Just extends WSToken
    toString:->"[Just]"

class Indent extends WSToken
    constructor:(@level)->
    toString:->"[Indent#{@level}]"

class NewLine extends WSToken
    toString:->"\n"

exports.WSManager=WSManager

# WSコード供給バッファ
class WSBuffer
    constructor:(@ops,@lv)->
        @index=-1    #@opsの
        @bindex=0   #@bufの
        @buf="" # 現在の
        @stream_mode=null
        @killed=false   # 使用不能か
    clone:->
        ret=new WSBuffer @ops.concat([]),@lv
        ret.index=@index
        ret.bindex=@bindex
        ret.buf=@buf
        ret.stream_mode=@stream_mode
        ret.killed=@killed
        ret
    takeJust:(type,last)->#type: "indent"/"just" どんなのが欲しいか last: 行末のスペースの場合
        if @killed
            throw new Error "dead"
        # スペースをとる
        unless @buf[@bindex]
            # 次の文字がない
            if @stream_mode=="push0-add"
                #Push0-Addロジック
                if last
                    # おわっていい
                    return null
                @buf+=" "
            else if @stream_mode=="push-free"
                # なにをPushしてもいいね
                if last
                    return null
                if type=="indent"
                    @buf+="\t"
                else
                    @buf+=" "
            else if !@ops[@index+1]
                # もうない!
                @buf="   "
                @bindex=0
                # あとはいくらスペースたしてもOK(Push 0になる)
                @stream_mode="push-free"
            else
                # 次の命令を供給
                @index++
                @buf=@ops[@index].getCode()
                @bindex=0
        char=@buf[@bindex]
        if char in [" ","\t"]
            ###
            process.stdout.write (switch char
                when " " then "[SP#{@bindex}]"
                when "\t" then "[TB#{@bindex}]"
            ).yellow
            ###
            @bindex++
            return char
        return null
    takeNewLine:->
        if @killed
            throw new Error "dead"
        unless @buf[@bindex]
            if @stream_mode=="push-free"
                # Pushを終了させる
                @buf+="\n"
                @stream_mode=null
            else if @stream_mode=="push0-add"
                # Push終了,addに移行
                @buf+="\n"
                @stream_mode=null
                @ops.splice @index+1,0,new operations.arithmetic.Add
            else if !@ops[@index+1]
                # Endでごまかす
                @buf="\n\n\n"
                @bindex=0
            else
                # 次の命令を供給
                @index++
                @buf=@ops[@index].getCode()
                @bindex=0
        char=@buf[@bindex]
        if char=="\n"
            #process.stdout.write "[LF#{@index}]".yellow
            @bindex++
            return char
        return null
    takeAll:->
        if @killed
            throw new Error "dead"
        result=@buf.slice @bindex
        for op in @ops.slice @index+1
            result+=op.getCode()
        @bindex=@buf.length
        @index=@ops.length-1
        result
    back:(num=1)->
        # 1つ戻る
        while num>=0
            if @bindex>=num
                # おわりだあああ
                @bindex-=num
                break
            # さらに戻る
            # @bindex=0
            num-=@bindex
            @index--
            if @index<0
                throw new Error "Cannot back"
            @buf=@ops[@index]
            @bindex=@buf.length
        return
        #process.stdout.write "back".red
    # インデントをとる
    takeIndent:(width,tabWidth,force)->
        # force: できるだけがんばってインデント(Push0-Add)
        if @killed
            throw new Error "dead"
        #width: 何文字分のインデントがほしいか tabWidth: タブは何文字分か
        result=""
        taken=0
        char=null
        while true
            char=@takeJust "indent"
            #console.log char?.charCodeAt(0),@buf,@bindex,@stream_mode
            switch char
                when " "
                    result+=" "
                    taken++
                when "\t"
                    result+="\t"
                    newtaken=(Math.floor(taken/tabWidth)+1)*tabWidth
                    if newtaken<=width
                        taken=newtaken
                    else
                        # 超えてしまった
                        unless force && @lv>=2
                            # 諦める
                            result=null
                            break
                        else
                            # 諦めない（Push 0でスペースを入れていく）
                            # 最初まで戻る
                            if @buf.slice(0,@bindex).indexOf("\n")>=0
                                # 改行にはさまってるじゃん・・・　これは無理
                                result=null
                                break
                            result=result.slice 0,result.length-@bindex
                            # 現在のインデント幅を計算し直す
                            taken=@calcIndent result,tabWidth
                            @buf="   "  #[SP][SP][SP]:Push
                            @bindex=0
                            @index--
                            # 次は命令セットから持ってくるかわりにPush0-Addロジック
                            @stream_mode="push0-add"
                else
                    # 足りなかった
                    unless force && @lv>=2
                        # やっぱ無理だわ…
                        result=null
                        break
                    else
                        # 諦めない（Push 0でスペースを入れていく）
                        # 最初まで戻る
                        if !@buf || @buf.slice(0,@bindex).indexOf("\n")>=0
                            # 改行にはさまってるじゃん・・・　これは無理
                            result=null
                            break
                        result=result.slice 0,result.length-@bindex
                        # 現在のインデント幅を計算し直す
                        taken=@calcIndent result,tabWidth
                        @buf="   "  #[SP][SP][SP]:Push
                        @bindex=0
                        @index--
                        # 次は命令セットから持ってくるかわりにPush0-Addロジック
                        @stream_mode="push0-add"
            unless result?
                result=null
                break
            if taken==width
                # インデント成功
                break
        unless result?
            # もうわけわからん
            @killed=true
        result
    calcIndent:(str,tabWidth)->
        # インデント文字列が何文字分か計算
        result=0
        for char in str
            switch char
                when " "
                    result++
                when "\t"
                    result=(Math.floor(result/tabWidth)+1)*tabWidth
        result
class Blender
    #tabWidth: タブがスペース何個分にあたるか indentWidth:インデントがスペース何個分にあたるか
    constructor:(@tabWidth,@indentWidth,@tokens,ops,@lv=1)->
        #@lv: コードをいじるレベル
        # バッファに入れる
        @ops=ops.concat []
        if @lv>=2
            # 最初にPushしておいてスタックにひとつもない状況を防ぐ（スタックアンダーフローするコードは知らん）
            @ops.unshift new operations.stack.Push 0
        @buffer=new WSBuffer @ops,@lv
        # スペースを水増しモード
        @infinity_spaces=false

    takeLine:->
        # 1行とる
        result=[]
        for t in @tokens
            result.push t
            if t instanceof NewLine
                break
        @tokens=@tokens.slice result.length
        result
    blend:->
        result=""
        while true
            line=@takeLine()
            if line.length==0
                # EOF
                break
            ifailureCount=0  # インデントに失敗した数
            while true
                # 行を生成する
                tmp=""
                buf=@buffer.clone()
                for t in line
                    if t instanceof WSToken
                        if t instanceof Indent
                            # 目標を定める
                            to=t.level*@indentWidth
                            #console.log "Indent! to #{to}".red
                            now=0
                            char=null
                            ###
                            while char=buf.takeJust "indent"
                                switch char
                                    when " "
                                        tmp+=" "
                                        now++
                                    when "\t"
                                        tmp+="\t"
                                        newnow=(Math.floor(now/@tabWidth)+1)*@tabWidth
                                        if newnow<=to
                                            now=newnow
                                        else
                                            # この行は無理だわ…
                                            tmp=null
                                            break
                                    else
                                        # やっぱ無理だわ…
                                        tmp=null
                                        break
                                if now==to
                                    # インデント成功
                                    #console.log "ok!".yellow,[].map.call(tmp,(x)->x.charCodeAt(0)).join()
                                    break
                            ###
                            indentstr=buf.takeIndent t.level*@indentWidth,@tabWidth,ifailureCount>=1
                            unless indentstr?
                                # この行はだめだわ
                                tmp=null
                                ifailureCount++
                                break
                            tmp+=indentstr
                            # ぶじインデントしたでー
                        else if t instanceof Just
                            # ひとつほしい
                            char=buf.takeJust "just"
                            unless char?
                                # 無理だわ…
                                tmp=null
                                break
                            tmp+=char
                        else if t instanceof NewLine
                            # 行がおわるぞ!
                            char=null
                            # 末尾にスペースを流し込む
                            while char=buf.takeJust "just",true
                                tmp+=char
                            char=buf.takeNewLine()
                            unless char?
                                throw new Error "What!? Invalid char on buf"
                            tmp+=char
                            # ミッションコンプリート(このあとは勝手にループを抜けるはず)
                    else
                        # ふつうのやつ
                        str=t.toString()
                        if /\u0020|\t/.test str
                            # スペース混ざってるぞ! 危険
                            idx=0
                            len=str.length
                            for ch in str
                                if ch in [" ","\t"]
                                    # これは危険だ!
                                    char=buf.takeJust "just"
                                    if ch==char
                                        # OK!
                                        tmp+=ch
                                        continue
                                    else if char?
                                        buf.back()
                                else
                                    # OK!
                                    tmp+=ch
                                    continue
                                # 変換が必要
                                switch ch
                                    when " "
                                        ch="\\u0020"
                                    when "\t"
                                        ch="\\t"
                                tmp+=ch
                        else
                            # 危険はない
                            tmp+=str
                unless tmp?
                    # 失敗している
                    # 仕方ないのでスペースだけで一行使う
                    tmp=""
                    char=null
                    buf=@buffer.clone()
                    while char=buf.takeJust "just",true
                        tmp+=char
                    char=buf.takeNewLine()
                    unless char?
                        throw new Error "What!?"
                    tmp+=char
                    result+=tmp
                    #process.stdout.write tmp.blue
                    # 次の行チャレンジ
                    @buffer=buf
                    continue
                # 行が完成した
                @buffer=buf
                result+=tmp
                #process.stdout.write tmp.blue
                break
        # 残っているやつは末尾に入れる
        str=null
        str=@buffer.takeAll()
        if str
            result+=str
            #process.stdout.write str.blue
        return result
exports.Blender=Blender




