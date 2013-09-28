operations=require './operations'
# 入力をメッセージにするぞ!
bufs=[]
process.stdin.resume()
###
process.stdin.on "readable",->
    bufs.push process.stdin.read()
###
process.stdin.on "data",(chunk)->
    bufs.push chunk

process.stdin.on "end",->
    # おわー
    all=Buffer.concat bufs
    # 積んでいくだけ。。。
    ops=[]
    ops.push new operations.stack.Push 0
    for char in all by -1
        # 逆に積む
        ops.push new operations.stack.Push char
    # ループで回す
    ops.push new operations.flow.Label " "
    ops.push new operations.stack.Duplicate
    ops.push new operations.flow.JumpZero "\t"
    ops.push new operations.io.OutputChar
    ops.push new operations.flow.Jump " "
    ops.push new operations.flow.Label "\t"
    ops.push new operations.flow.End

    # 出力する
    process.stdout.write ops.map((x)->
        x.getCode()
    ).join ""
