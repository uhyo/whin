parser=require '../js/parser'
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
    constructor:(@buffer)->
        @index=0
        @push0_mode=false
    clone:->
        ret=new WSBuffer @buffer
        ret.index=@index
        ret.push0_mode=@push0_mode
        ret
    takeJust:(last)->#last: 行末のスペースの場合
        # スペースをとる
        unless @buffer[@index]
            # もうない!
            if @push0_mode
                if last
                    # もう終わっていいよ!
                    return null
                @buffer+=" "
            else
                @buffer+="   "
                # あとはいくらスペースたしてもOK(Push 0になる)
                @push0_mode=true
        char=@buffer[@index]
        if char in [" ","\t"]
            ###
            process.stdout.write (switch char
                when " " then "[SP#{@index}]"
                when "\t" then "[TB#{@index}]"
            ).yellow
            ###
            @index++
            return char
        return null
    takeNewLine:->
        unless @buffer[@index]
            if @push0_mode
                # Push 0を終了させる
                @buffer+="\n"
                @push0_mode=false
            else
                # Endでごまかす
                @buffer+="\n\n\n"
        char=@buffer[@index]
        if char=="\n"
            #process.stdout.write "[LF#{@index}]".yellow
            @index++
            return char
        return null
    takeAll:->
        result=@buffer.slice @index
        @index=@buffer.length
        result
    back:(num=1)->
        # 戻る
        @index-=num
        if @index<0
            @index=0
        #process.stdout.write "back".red


class Blender
    #tabWidth: タブがスペース何個分にあたるか indentWidth:インデントがスペース何個分にあたるか
    constructor:(@tabWidth,@indentWidth,@tokens,@ops)->
        # バッファに入れる
        @buffer=new WSBuffer @ops.map((x)->x.getCode()).join ""
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
                            while char=buf.takeJust()
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
                            unless tmp?
                                break
                            if now<to
                                # 足りなかった・・・
                                tmp=null
                                break
                            # ぶじインデントしたでー
                        else if t instanceof Just
                            # ひとつほしい
                            char=buf.takeJust()
                            unless char?
                                # 無理だわ…
                                tmp=null
                                break
                            tmp+=char
                        else if t instanceof NewLine
                            # 行がおわるぞ!
                            char=null
                            # 末尾にスペースを流し込む
                            while char=buf.takeJust true
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
                                    char=buf.takeJust()
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
                    while char=buf.takeJust()
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



