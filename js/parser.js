// JS Parser by Uhyo

function ParseDefinisionsReal(){
	var d={};
	d.WhiteSpace=/\s/;
	d.LineTerminator=/(?:\r\n|[\r\n\u2028\u2029])/;
	//
	var identifierStart=/(?:\\u\d{4}|[\u0041-\u005a\u005f\u0061-\u007a\u00aa\u00b5\u00ba\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec\u02ee\u0370-\u0374\u0376-\u0377\u037a-\u037d\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u048a-\u0527\u0531-\u0556\u0559\u0561-\u0587\u05d0-\u05ea\u05f0-\u05f2\u0620-\u064a\u066e-\u066f\u0671-\u06d3\u06d5\u06e5-\u06e6\u06ee-\u06ef\u06fa-\u06fc\u06ff\u0710\u0712-\u072f\u074d-\u07a5\u07b1\u07ca-\u07ea\u07f4-\u07f5\u07fa\u0800-\u0815\u081a\u0824\u0828\u0840-\u0858\u0904-\u0939\u093d\u0950\u0958-\u0961\u0971-\u0977\u0979-\u097f\u0985-\u098c\u098f-\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bd\u09ce\u09dc-\u09dd\u09df-\u09e1\u09f0-\u09f1\u0a05-\u0a0a\u0a0f-\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32-\u0a33\u0a35-\u0a36\u0a38-\u0a39\u0a59-\u0a5c\u0a5e\u0a72-\u0a74\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2-\u0ab3\u0ab5-\u0ab9\u0abd\u0ad0\u0ae0-\u0ae1\u0b05-\u0b0c\u0b0f-\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32-\u0b33\u0b35-\u0b39\u0b3d\u0b5c-\u0b5d\u0b5f-\u0b61\u0b71\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99-\u0b9a\u0b9c\u0b9e-\u0b9f\u0ba3-\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bd0\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c33\u0c35-\u0c39\u0c3d\u0c58-\u0c59\u0c60-\u0c61\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd\u0cde\u0ce0-\u0ce1\u0cf1-\u0cf2\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d\u0d4e\u0d60-\u0d61\u0d7a-\u0d7f\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0e01-\u0e30\u0e32-\u0e33\u0e40-\u0e46\u0e81-\u0e82\u0e84\u0e87-\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa-\u0eab\u0ead-\u0eb0\u0eb2-\u0eb3\u0ebd\u0ec0-\u0ec4\u0ec6\u0edc-\u0edd\u0f00\u0f40-\u0f47\u0f49-\u0f6c\u0f88-\u0f8c\u1000-\u102a\u103f\u1050-\u1055\u105a-\u105d\u1061\u1065-\u1066\u106e-\u1070\u1075-\u1081\u108e\u10a0-\u10c5\u10d0-\u10fa\u10fc\u1100-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1380-\u138f\u13a0-\u13f4\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16ee-\u16f0\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17d7\u17dc\u1820-\u1877\u1880-\u18a8\u18aa\u18b0-\u18f5\u1900-\u191c\u1950-\u196d\u1970-\u1974\u1980-\u19ab\u19c1-\u19c7\u1a00-\u1a16\u1a20-\u1a54\u1aa7\u1b05-\u1b33\u1b45-\u1b4b\u1b83-\u1ba0\u1bae-\u1baf\u1bc0-\u1be5\u1c00-\u1c23\u1c4d-\u1c4f\u1c5a-\u1c7d\u1ce9-\u1cec\u1cee-\u1cf1\u1d00-\u1dbf\u1e00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u2071\u207f\u2090-\u209c\u2102\u2107\u210a-\u2113\u2115\u2119-\u211d\u2124\u2126\u2128\u212a-\u212d\u212f-\u2139\u213c-\u213f\u2145-\u2149\u214e\u2160-\u2188\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cee\u2d00-\u2d25\u2d30-\u2d65\u2d6f\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u2e2f\u3005-\u3007\u3021-\u3029\u3031-\u3035\u3038-\u303c\u3041-\u3096\u309d-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312d\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400\u4db5\u4e00\u9fcb\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua61f\ua62a-\ua62b\ua640-\ua66e\ua67f-\ua697\ua6a0-\ua6ef\ua717-\ua71f\ua722-\ua788\ua78b-\ua78e\ua790-\ua791\ua7a0-\ua7a9\ua7fa-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua840-\ua873\ua882-\ua8b3\ua8f2-\ua8f7\ua8fb\ua90a-\ua925\ua930-\ua946\ua960-\ua97c\ua984-\ua9b2\ua9cf\uaa00-\uaa28\uaa40-\uaa42\uaa44-\uaa4b\uaa60-\uaa76\uaa7a\uaa80-\uaaaf\uaab1\uaab5-\uaab6\uaab9-\uaabd\uaac0\uaac2\uaadb-\uaadd\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uabc0-\uabe2\uac00\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf900-\ufa2d\ufa30-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d\ufb1f-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40-\ufb41\ufb43-\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfb\ufe70-\ufe74\ufe76-\ufefc\uff21-\uff3a\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc])/;

	var identifierPart=/[\u0030-\u0039\u005f\u0660-\u0669\u06f0-\u06f9\u07c0-\u07c9\u0966-\u096f\u09e6-\u09ef\u0a66-\u0a6f\u0ae6-\u0aef\u0b66-\u0b6f\u0be6-\u0bef\u0c66-\u0c6f\u0ce6-\u0cef\u0d66-\u0d6f\u0e50-\u0e59\u0ed0-\u0ed9\u0f20-\u0f29\u1040-\u1049\u1090-\u1099\u17e0-\u17e9\u1810-\u1819\u1946-\u194f\u19d0-\u19d9\u1a80-\u1a89\u1a90-\u1a99\u1b50-\u1b59\u1bb0-\u1bb9\u1c40-\u1c49\u1c50-\u1c59\u203f-\u2040\u2054\ua620-\ua629\ua8d0-\ua8d9\ua900-\ua909\ua9d0-\ua9d9\uaa50-\uaa59\uabf0-\uabf9\ufe33-\ufe34\ufe4d-\ufe4f\uff10-\uff19\uff3f]/;
	d.Identifier=new RegExp(ee(identifierStart)+"(?:"+ee(identifierStart)+"|"+ee(identifierPart)+"|[\\u200c\\u200d])*");
	d.Punctuator=new RegExp("(?:"+
				["{","}","(",")","[","]",".",";",",","<",">","<=",">=","==","!=","===","!==",
				 "+","-","*","/","%","++","--","<<",">>",">>>","&","|","^","!","~","&&","||",
				 "?",":","=","+=","-=","*=","/=","%=","<<=",">>=",">>>=","&=","|=","^="].sort(function(a,b){
					return b.length-a.length;
				}).map(function(x){
					return Array.prototype.map.call(x,function(y){return "\\"+y}).join("");
				}).join("|")+
			       ")");
	d.DivPunctuator=/(?:\/|\/\=)/;
	var decimalLiteral=/(?:0[Xx][0-9a-fA-F]+|(?:0|[1-9]\d*)(?:\.\d+)?(?:[Ee][\+\-]?\d+)?|\.\d+(?:[Ee][\+\-]?\d+)?)/;
	d.Literal=new RegExp("(?:"+ee(/(?:null|true|false|(?:\r\n|[\r\n\u2028\u2029]))/)+"|"+ee(decimalLiteral)+")\\b");
	d.Comment=/(?:\/\/.*|\/\*(?:.|(?:\r\n|[\r\n\u2028\u2029]))*?\*\/)/;
	d.StringLiteral=/(?:\"(?:\\(?:\r\n|[\r\n\u2028\u2029])|\\(?:[^xu0-9]|0(?![0-9])|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})|[^\\\"])*?\"|\'(?:\\(?:\r\n|[\r\n\u2028\u2029])|\\(?:[^xu0-9]|0(?![0-9])|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})|[^\\\'])*?\')/;
	d.RegExpLiteral=/\/(?:\\.|[^\/\\\[]|\[(?:\\.|[^\]\\])+?\])+?\/\w*/;
	this.defs=d;
	
	this.keywords=["break","case","catch","continue","debugger","default","delete","do","else","finally","for","function","if","in","instanceof","new","return","switch","this","throw","try","typeof","var","void","while","with"];
	this.futureReservedWords=["class","const","enum","export","extends","import","super",
				 "implements","interface","let","package","private","protected","public","static","yield"];
	//演算子の優先順位
	this.exps=[",",
		["=","*=","/=","%=","+=","-=","<<=",">>=",">>>=","&=","^=","|="],
		"?:",
		"||",
		"&&",
		"|",
		"^",
		"&",
		["==","!=","===","!=="],
		["<",">","<=",">=","instanceof","in"],
		["<<",">>",">>>"],
		["+","-"],
		["*","/","%"],
		["delete","void","typeof","++","--","+","-","~","!"],
		["++","--"],
		"new",
	       ];

	//regexp用にエスケープ
	function e(str){
		//return str.replace("\\","\\\\");
		return str;
	}
	function ee(reg){
		return e(reg.source);
	}
}
ParseDefinisions.prototype={
};
function ParseDefinisions(){
	ParseDefinisionsReal.apply(this);
}
ParseDefinisions.prototype=Object.create(ParseDefinisionsReal.prototype);
//パーサーの本体
function JSParser(){
	ParseDefinisions.apply(this);
}
JSParser.prototype=Object.create(ParseDefinisions.prototype);
JSParser.prototype.tokenize=function(str){
	var tokens=new TokenList();
	var d=this.defs;
	var wss=new RegExp("^"+ee(d.WhiteSpace)+"+");//空白
	var lin=new RegExp("^"+ee(d.LineTerminator)+"+");//改行
	var com=new RegExp("^"+ee(d.Comment));	//コメント
	var pun=new RegExp("^"+ee(d.Punctuator));	//演算子
	var lit=new RegExp("^"+ee(d.Literal));	//リテラル（null、真偽値、数値）
	var stl=new RegExp("^"+ee(d.StringLiteral));//文字列
	var rgl=new RegExp("^"+ee(d.RegExpLiteral));//正規表現
	var ide=new RegExp("^"+ee(d.Identifier));	//識別子
	
	//識別子
	var th=this;
	var ide_switch=function(v){
		if(th.keywords.indexOf(v)>=0)return new KeywordToken(v);
		if(th.futureReservedWords.indexOf(v)>=0)return new FutureReservedWordToken(v);
		return new IdentifierToken(v);
	};
	var pun_switch=function(v){
		if(v=="/" || v=="/="){
			if(!tokens.length)return new UndefinedToken();
			var last=tokens[tokens.length-1];
			//console.log(last);
			if(last instanceof LiteralToken || last instanceof IdentifierToken)return new PunctuatorToken(v);
			return new UndefinedToken();
		}
		return new PunctuatorToken(v);
	}
	
	var patterns=[[lin,LineTerminatorToken],[wss,WhiteSpaceToken],[com,CommentToken],[pun,pun_switch],[rgl,RegExpLiteralToken],
		      [lit,LiteralToken],[stl,StringLiteralToken],[ide,ide_switch]];
	mainLoop:while(str){
		var result;
		for(var i=0,l=patterns.length;i<l;i++){
			if(result=str.match(patterns[i][0])){
				var newtoken=new patterns[i][1](result[0]);
				if(newtoken instanceof UndefinedToken)continue;
				tokens.push(newtoken);
				str=str.slice(result[0].length);
				continue mainLoop;
			}
		}
		throw new Error(str);
	}
	return tokens;
	//regexp用にエスケープ
	function e(str){
		//return str.replace("\\","\\\\");
		return str;
	}
	function ee(reg){
		return e(reg.source);
	}
};
//引数:TokenList
JSParser.prototype.parse=function(str){
	var th=this;
	var tokens=new LiveTokenList(str);
	var statements=getStatements();
	if(a=tokens.iterate()){
		//console.log(a);
		throw new SyntaxError();
	}
	return statements;
	
	//modeがtrue: statementだけでなくFunctionDeclarationも得る
	function getStatements(mode){
		var statements=new (mode? Statements : SourceElements)();
		while(true){
			var st=getStatement();
			if(st){
				statements.push(st);
				continue;
			}
			st=getFunctionDeclaration(true);
			if(st){
				statements.push(st);
				continue;
			}
			break;
			
		}
		return statements;
	}
	
	//ステートメントを解釈して返す
	//失敗したらnullを返す
	function getStatement(){
		var next=tokens.iterate();
		if(!next){
			tokens.back(null);
			return false;
		}
		//BlockStatement
		if(next.equal(PunctuatorToken,"{")){
			var ret=new BlockStatement();
			var st;
			while(st=getStatement()){
				ret.statements.push(st);
			}
			getNext(PunctuatorToken,"}");
			tokens.save();
			return ret;
		}
		//VariableStatement
		if(next.equal(KeywordToken,"var")){
			//VariableDeclarationListの解析
			//VariableDeclarationの解析
			var ret=new VariableStatement();
			while(true){
				if(ret.variables.length>0){
					if(!getNext(PunctuatorToken,",",false)){
						break;
					}
				}
				var iden = getNext(IdentifierToken);
				if(getNext(PunctuatorToken,"=",false)){
					//AssignmentExpression解釈
					var exp=getExpression(1);
					if(!exp)throw new SyntaxError();
					ret.variables.push([iden,exp]);
				}else{
					ret.variables.push([iden,null]);
				}
			}
			if(ret.variables.length==0)throw new SyntaxError();
			getSemicolon();
			return ret;
		}
		//IfStatement
		if(next.equal(KeywordToken,"if")){
			getNext(PunctuatorToken,"(");
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			getNext(PunctuatorToken,")");
			var st1=getStatement();
			if(!st1)throw new SyntaxError();
			var ret=new IfStatement();
			ret.condition=exp;
			ret.truestatement=st1;
			if(getNext(KeywordToken,"else",false)){
				var st2=getStatement();
				if(!st2)throw new SyntaxError();
				ret.elsestatement=st2;
			}
			return ret;
		}
		//IterationStatement
		if(next.equal(KeywordToken,"do")){
			//do-while
			var st=getStatement();
			if(!st)throw new SyntaxError();
			getNext(KeywordToken,"while");
			getNext(PunctuatorToken,"(");
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			getNext(PunctuatorToken,")");
			var ret=new Do_WhileStatement();
			ret.condition=exp,ret.statement=st;
			return ret;
		}
		if(next.equal(KeywordToken,"while")){
			//while
			getNext(PunctuatorToken,"(");
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			getNext(PunctuatorToken,")");
			var st=getStatement();
			if(!st)throw new SyntaxError();
			var ret=new WhileStatement();
			ret.condition=exp,ret.statement=st;
			return ret;
		}
		if(next.equal(KeywordToken,"for")){
			//for
			getNext(PunctuatorToken,"(");
			var variables=null;	//varをつかう場合のみ
			var exp1,exp2,exp3,st;
			if(getNext(KeywordToken,"var",false)){
				var variables=[];
				while(true){
					if(variables.length>0){
						if(!getNext(PunctuatorToken,",",false)){
							break;
						}
					}
					var iden = getNext(IdentifierToken);
					if(getNext(PunctuatorToken,"=",false)){
						//AssignmentExpression解釈
						var exp=getExpression(1,true);
						if(!exp)throw new SyntaxError();
						variables.push([iden,exp]);
					}else{
						variables.push([iden,null]);
					}
				}
				if(variables.length==0)throw new SyntaxError();
			}else{
				exp1=getExpression(null,true);
			}
			if(getNext(PunctuatorToken,";",false)){
				//for
				exp2=getExpression();	//nullでもOK
				getNext(PunctuatorToken,";");
				exp3=getExpression();	//nullでもOK
				getNext(PunctuatorToken,")");
				st=getStatement();
				if(!st)throw new SyntaxError();
				var ret;
				if(variables){
					ret=new For_VarStatement();
					ret.variables=variables;
				}else{
					ret=new ForStatement();
					ret.exp1=exp1;
				}
				ret.exp2=exp2,ret.exp3=exp3,ret.statement=st;
				return ret;
			}
			if(variables){
				if(variables.length!=1)throw new SyntaxError();
			}
			if(getNext(KeywordToken,"in",false)){
				exp2=getExpression();
				getNext(PunctuatorToken,")");
				st=getStatement();
				if(!st)throw new SyntaxError();
				var ret;
				if(variables){
					ret=new For_In_VarStatement();
					ret.variables=variables;
				}else{
					ret=new For_InStatement();
					ret.exp1=exp1;
				}
				ret.exp2=exp2,ret.statement=st;
				return ret;
			}
			throw new SyntaxError();
		}
		//ContinueStatement BreakStatement ReturnStatement
		if(next.equal(KeywordToken,"continue") || next.equal(KeywordToken,"break") || next.equal(KeywordToken,"return")){
			var ret;
			if(next.equal(KeywordToken,"continue"))ret=new ContinueStatement();
			if(next.equal(KeywordToken,"break"))ret=new BreakStatement();
			if(next.equal(KeywordToken,"return"))ret=new ReturnStatement();
			if(getNext(LineTerminatorToken,null,false,true)){
				//改行があるぞ！
				tokens.back(null);
				getSemicolon();
				return ret;
			}
			var next2;
			if(ret instanceof ReturnStatement){
				next2=getExpression();	//nullでもいい
				if(next2)ret.exp=next2;
			}else{
				next2=getNext(IdentifierToken,null,false);
				if(next2)ret.identifier=next2;
			}
			getSemicolon();
			return ret;
		}
		//WithStatement
		if(next.equal(KeywordToken,"with")){
			getNext(PunctuatorToken,"(");
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			getNext(PunctuatorToken,")");
			var st=getStatement();
			if(!st)throw new SntaxError();
			var ret=new WithStatement();
			ret.exp=exp,ret.statement=st;
			return ret;
		}
		//SwitchStatement
		if(next.equal(KeywordToken,"switch")){
			getNext(PunctuatorToken,"(");
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			getNext(PunctuatorToken,")");
			var ret=new SwitchStatement();
			ret.exp=exp;
			getNext(PunctuatorToken,"{");
			var default_flg=false;
			while(true){
				if(getNext(KeywordToken,"case",false)){
					//case
					var exp=getExpression();
					if(!exp)throw new SyntaxError();
					getNext(PunctuatorToken,":");
					var sts=getStatements();
					ret.cases.push([exp,sts,false]);
					continue;
				}else if(getNext(KeywordToken,"default",false)){
					//default
					if(default_flg)throw new SyntaxError();
					getNext(PunctuatorToken,":");
					var sts=getStatements();
					ret.cases.push([null,sts,true]);
					continue;
				}
				getNext(PunctuatorToken,"}");
				break;
			}
			return ret;
		}
		//LabelledStatement
		if(next instanceof IdentifierToken){
			if(getNext(PunctuatorToken,":",false)){
				var st=getStatement();
				var ret=new LabelledStatement();
				ret.identifier=next;
				ret.statement=st;
				return ret;
			}
		}
		//ThrowStatement
		if(next.equal(KeywordToken,"throw")){
			if(getNext(LineTerminatorToken,null,false)){
				//改行があるぞ！
				throw new SyntaxError();
			}
			var exp=getExpression();
			if(!exp)throw new SyntaxError();
			var ret=new ThrowStatement();
			ret.exp=exp;
			return ret;
		}
		//TryStatement
		if(next.equal(KeywordToken,"try")){
			var st=getBlock();
			var ret=new TryStatement();
			ret.block=st;
			if(getNext(KeywordToken,"catch",false)){
				//catch
				getNext(PunctuatorToken,"(");
				var ide=getNext(IdentifierToken);
				getNext(PunctuatorToken,")");
				var st2=getBlock();
				ret.catchidentifier=ide;
				ret.catchblock=st2;
			}
			if(getNext(KeywordToken,"finally",false)){
				//finally
				var st3=getBlock();
				ret.finallyblock=st3;
			}
			if(!(ret.catchblock||ret.finallyblock)){
				//catchもfinallyもない
				throw new SyntaxError();
			}
			return ret;
		}
		//DebuggerStatement
		if(next.equal(KeywordToken,"debugger")){
			getSemicolon();
			return new DebuggerStatement();
		}
		
		
		
		//ExpressionStatement
		if(!next.equal(KeywordToken,"function")){
			tokens.back(null);
			var exp=getExpression();
			if(exp){
				var ret=new ExpressionStatement();
				ret.exp=exp;
				getSemicolon();
				return ret;
			}
		}else{
			tokens.back(null);
		}
		//EmptyStatement
		if(getSemicolon(false)){
			return new EmptyStatement();
		}
		return null;
	}
	//Blockをぜったい得る。得られなかったらエラー
	function getBlock(){
		//BlockStatement
		if(!getNext(PunctuatorToken,"{"))throw new SyntaxError();
		var ret=new BlockStatement();
		var st;
		while(st=getStatement()){
			ret.statements.push(st);
		}
		getNext(PunctuatorToken,"}");
		return ret;
	}
	//次のトークンを得る。失敗したらエラー ただしerrorがfalseの場合はnullを返す
	//modeがtrue→LineTerminatorを無視しない
	function getNext(type,value,error,mode){
		var ret=tokens.iterate(!!mode);
		try{
			if(!ret || !(ret instanceof type)){
				tokens.back(null);
				if(error===false)return null;
				throw new SyntaxError("Expected "+type.name+", got "+ret.toString());
			}
			if(value && ret.value!=value){
				tokens.back(null);
				if(error===false)return null;
				//console.log(value+" != "+ret.value);
				throw new SyntaxError(error);
			}
		}catch(e){
			if(e instanceof SyntaxError){
				if(!ret){
					var p=new PunctuatorToken(";");
					p.raw_str=";";
					tokens.unshift(p);
					return getNext(type,value,error,mode);
				}else if(getNext(LineTerminatorToken,null,false,true)){
					//LineTerminatorがある
					tokens.back(null);
					var p=new PunctuatorToken(";");
					p.raw_str=";";
					tokens.unshift(p);
					return getNext(type,value,error,mode);
				}else if(getNext(PunctuatorToken,"}",false)){
					//}
					tokens.back(null);
					var p=new PunctuatorToken(";");
					p.raw_str=";";
					tokens.unshift(p);
					return getNext(type,value,error,mode);
				}
				throw e;
			}
		}
		return ret;
	}
	//番号（expsを上から見て）
	function getExpression(expnum,noin){
		if(!expnum){
			expnum=0;
		}
		var right = expnum==1 || expnum==2 || expnum==13;	//右から
		var enz;
		if(expnum<th.exps.length){
			//まだ演算子が残っている
			enz=th.exps[expnum];
			if(noin){
				if(enz instanceof Array){
					enz=enz.filter(function(x){return x!="in"});
				}else{
					if(enz=="in")return getExpression(expnum+1,noin);
				}
			}
			if(expnum==2){
				//条件演算子 ?: かも
				var ret=new Expression();
				var exp=getExpression(expnum+1,noin);
				var next=tokens.iterate(true);
				if(next && next.value=="?"){
					//三項演算子だ！
					ret.parts.push(exp);
					ret.parts.push(next);
					exp=getExpression(1);
					if(!exp){
						throw new SyntaxError();
					}
					ret.parts.push(exp);
					ret.parts.push(getNext(PunctuatorToken,":"));
					exp=getExpression(1);
					if(!exp){
						throw new SyntaxError();
					}
					ret.parts.push(exp);
					return ret;
					
				}else{
					//ふつうだ！
					tokens.back(null);
					return exp;
				}
			}else if(expnum==13){
				//単項演算子（左から）
				var next=tokens.iterate();
				if(!next)throw new SyntaxError();
				if(enz instanceof Array? enz.indexOf(next.value)>=0 : next.value==enz){
					//演算子があった！
					if(getNext(LineTerminatorToken,null,false,true)){
						//改行
						throw new SyntaxError();
					}
					var ret=new Expression();
					ret.parts.push(next);
					var exp=getExpression(expnum,noin);
					if(exp)ret.parts.push(exp);
					else throw new SyntaxError();
					return ret;
				}else{
					//演算子がなかった！
					tokens.back(null);
					return getExpression(expnum+1,noin);
				}
			}else if(expnum==14 || expnum==15){
				//単項演算子（右から）
				var exp=getExpression(expnum+1,noin);
				if(!exp)return null;
				var next=tokens.iterate(true);	//改行はなし
				if(next && (enz instanceof Array? enz.indexOf(next.value)>=0 : next.value==enz)){
					//演算子があった！
					var ret=new Expression();
					ret.parts.push(exp);
					ret.parts.push(next);
					return ret;
				}else{
					//演算子がなかった！
					tokens.back(null);
					return exp;
				}

			}else if(right){
				//右から
				var exp = getExpression(expnum+1,noin);	//次の演算子
				if(!exp){
					//もう何も無い
					return null;
				}
				var next=tokens.iterate(true);
				if(next && (enz instanceof Array? enz.indexOf(next.value)>=0 : next.value==enz)){
					//次が演算子だ！
					var ret=new Expression();	//結果
					ret.parts.push(exp);
					ret.parts.push(next);
					exp = getExpression(expnum,noin);	//並列
					if(!exp){
						//演算子の続きがない
						throw new SyntaxError();
					}
					ret.parts.push(exp);
					return ret;
				}else{
					tokens.back(null);
					return exp;
				}
			}else{
				//左から
				var ret=null;
				var exp;
				//[[[[],[]],[]],[]] という感じ
				while(true){
					var exp=getExpression(expnum+1,noin);
					if(!exp){
						return null;
					}
					if(!ret){
						ret=new Expression();
						ret.parts.push(exp);
					}else{
						ret.parts.push(exp);
						var ret2=new Expression();
						ret2.parts.push(ret);
						ret=ret2;
					}
					var next=tokens.iterate(null,true);
					if(!next)break;
					if(enz instanceof Array? enz.indexOf(next.value)>=0 : next.value==enz){
						ret.parts.push(next);
					}else{
						//続きはない
						tokens.back(null);
						break;
					}
				}
				if(ret.parts.length==1)return ret.parts[0];	//二重になるのは防ぐ
				return ret;
			}
		}else{
			//もう演算子がない MemberExpression
			//いろいろ
			var exp=null;
			do{
				if(exp=getPrimaryExpression(noin))break;

				if(exp=getFunctionDeclaration())break;

				var next=getNext(KeywordToken,"new",false);
				if(next){
					var exp=new Expression();
					var exp2=getExpression(expnum+1,noin);	//関数呼び出しの括弧はいらない
					if(!exp2)throw new SyntaxError();
					exp.parts.push(next);
					exp.parts.push(exp2);
					
					if(getNext(PunctuatorToken,"(",false)){
						var paramlist=new Arguments();
						while(true){
							if(paramlist.length>0){
								if(!getNext(PunctuatorToken,",",false)){
									break;
								}
								var next2=getExpression(2);
								if(!next2)throw new SyntaxError();
								paramlist.push(next2);
							}else{
								var next2=getExpression(2);
								if(!next2)break;
								paramlist.push(next2);					
							}
						}
						getNext(PunctuatorToken,")");
						exp.parts.push(paramlist);
					}
					break;
				}
			}while(false);
			//[]と . ()の処理
			var kakko_done=!(expnum==th.exps.length);	//関数呼び出しのカッコは2つ辛ならない??・expnumがふえて呼ばれた場合は括弧で止まる
			while(true){
				var next;
				if(next=getNext(PunctuatorToken,"[",false)){
					var exp2=getExpression();
					if(!exp2)throw new SyntaxError();
					var newexp=new Expression();
					newexp.parts.push(exp);
					newexp.parts.push(next);
					newexp.parts.push(exp2);
					newexp.parts.push(getNext(PunctuatorToken,"]"));
					exp=newexp;
					kakko_done=false;
					continue;
				}
				if(next=getNext(PunctuatorToken,".",false)){
					var newexp=new Expression();
					newexp.parts.push(exp);
					newexp.parts.push(next);
					newexp.parts.push(getNext(IdentifierToken));
					exp=newexp;
					kakko_done=false;
					continue;
				}
				if((!kakko_done) && (next=getNext(PunctuatorToken,"(",false))){
					//関数呼び出し
					var newexp=new Expression();
					newexp.parts.push(exp);
					//newexp.parts.push(next);
					var paramlist=new Arguments();
					while(true){
						if(paramlist.length>0){
							if(!getNext(PunctuatorToken,",",false)){
								break;
							}
							var next2=getExpression(1);
							if(!next2)throw new SyntaxError();
							paramlist.push(next2);
						}else{
							var next2=getExpression(1);
							if(!next2)break;
							paramlist.push(next2);					
						}
					}
					newexp.parts.push(paramlist);
					//newexp.parts.push(getNext(PunctuatorToken,")"));
					getNext(PunctuatorToken,")");
					exp=newexp;
					continue;
				}
				break;
			}
			
			
			return exp;	//もう何も無いならばnull
		}
	}
	function getPrimaryExpression(noin){
		var next=tokens.iterate();
		if(!next)return null;
		if(next.value=="this" || next instanceof IdentifierToken || next instanceof LiteralToken){
			//this
			var ret=new Expression();
			ret.parts.push(next);
			return ret;
		}
		if(next.value=="("){
			var ret=new Expression();
			ret.parts.push(next);
			var exp=getExpression(null,noin);
			if(!exp)throw new SyntaxError();
			ret.parts.push(exp);
			ret.parts.push(getNext(PunctuatorToken,")"));
			return ret;
		}
		tokens.back(null);
		return getLiteral2();
		
	}
	//配列・オブジェクトリテラル
	function getLiteral2(){
		var next=tokens.iterate();
		if(!next)return null;
		if(next.value=="["){
			//ArrayLiteral
			var ret=new ArrayLiteral();
			while(true){
				var next2=getNext(PunctuatorToken,",",false);
				if(next2){
					//コンマ
					ret.parts.push(next2);
				}else if(next2=getNext(PunctuatorToken,"]",false)){
					//終了
					break;
				}else{
					var exp=getExpression(1);	//AssignmentExpression
					if(!exp)throw new SyntaxError();
					ret.parts.push(exp);
				}
				
			}
			return ret;
		}
		if(next.value=="{"){
			var ret=new ObjectLiteral();
			while(true){
				var next2=tokens.iterate();
				if(!next2)throw new SyntaxError();
				if(next2.value==","){
					//コンマ
					continue;
				}else if(next2.value=="}"){
					//終了
					break;
				}
				if(next2.value=="get"){
					//ゲッタ
					next2=tokens.iterate();
					if(!(next2 instanceof IdentifierToken || next2 instanceof StringLiteralToken || next2 instanceof LiteralToken)){
						throw new SyntaxError();
					}
					//カッコ
					var func=new FunctionDeclaration();
					getNext(PunctuatorToken,"(") && getNext(PunctuatorToken,")");
					getNext(PunctuatorToken,"{");
					var body=getFunctionBody();
					getNext(PunctuatorToken,"}");
					func.name=next2,func.paramlist=[],func.functionbody=body;
					ret.properties.push([next2,func,"get"]);
				}else if(next2.value=="set"){
					//セッタ
					next2=tokens.iterate();
					if(!(next2 instanceof IdentifierToken || next2 instanceof StringLiteralToken || next2 instanceof LiteralToken)){
						throw new SyntaxError();
					}
					getNext(PunctuatorToken,"(");
					var next3=getNext(IdentifierToken);	//引数
					getNext(PunctuatorToken,")");
					getNext(PunctuatorToken,"{");
					var body=getFunctionBody();
					getNext(PunctuatorToken,"}");
					var func=new FunctionDeclaration();
					func.name=next2,func.paramlist=[next3],func.functionbody=body;
					ret.properties.push([next2,func,"set"]);
				}else{
					if(!(next2 instanceof IdentifierToken || next2 instanceof StringLiteralToken || next2 instanceof LiteralToken)){
						throw new SyntaxError();
					}
					getNext(PunctuatorToken,":");
					var exp=getExpression(2);
					if(!exp)throw new SyntaxError();
					ret.properties.push([next2,exp,""]);
				}
				
			}
			return ret;
		}
		tokens.back(null);
		return null;
	}
	//modeがtrue: 名前の省略を許さない. false:FunctionExpression
	function getFunctionDeclaration(mode){
		var next=getNext(KeywordToken,"function",false);
		if(!next)return null;
		var ide=getNext(IdentifierToken,null,false);
		if(mode && !ide)throw new SyntaxError();
		if(!ide)ide=null;
		getNext(PunctuatorToken,"(");
		var paramlist=[];
		while(true){
			if(paramlist.length>0){
				if(!getNext(PunctuatorToken,",",false)){
					break;
				}
				var next2=getNext(IdentifierToken);
				paramlist.push(next2);
			}else{
				var next2=getNext(IdentifierToken,null,false);
				if(!next2)break;
				paramlist.push(next2);					
			}

		}
		getNext(PunctuatorToken,")");
		// 独自拡張文法（関数の返り値）
		var ide2;
		if(next=getNext(PunctuatorToken,":",false)){
			ide2=getNext(IdentifierToken);
			if(ide2.value!=="string" && ide2.value!=="number" && ide2.value!=="boolean"){
				throw new SyntaxError();
			}
		}
		getNext(PunctuatorToken,"{");
		var body=getFunctionBody();
		getNext(PunctuatorToken,"}");
		var ret= mode ? new FunctionDeclaration() : new FunctionExpression();
		ret.name=ide;
		ret.functionbody=body;
		ret.paramlist=paramlist;
		//独自拡張
		ret.returnType=ide2 && ide2.value;
		return ret;
	}
	function getFunctionBody(){
		var ret= new SourceElements();
		while(true){
			var exp=getFunctionDeclaration(true);
			if(exp){
				ret.push(exp);
				continue;
			}
			var st=getStatement();
			if(st){
				ret.push(st);
				continue;
			}
			break;
		}
		return ret;
	}
	function getSemicolon(mode){
		return getNext(PunctuatorToken,";",mode);
	}
};

//配列をコピー
JSParser.prototype.cloneArray=function(arr){
	if(!(arr instanceof Array))return arr;
	var ret=new arr.constructor();
	arr.forEach(function(x,i){
		ret[i]=x;
	});
	return ret;
};
//トークンリスト
function TokenList(){
	Array.apply(this);
	for(var i=0;i<arguments.length;i++){
		if(arguments[i] instanceof Array){
			arguments[i].forEach(function(x){
				this.push(x);
			},this);
		}else{
			this.push(arguments[i]);
		}
	}
	
	this.junk=[];	//イテレータで取り出されたもの
	this.last_iterate=[];	//最後のイテレートで取り出された個数（スタック）
}
TokenList.prototype=Object.create(Array.prototype);
TokenList.prototype.toString=function(){
	return this.reduce(function(sum,x){
		return sum+x.toString();
	},"");
};
TokenList.prototype.toHTML=function(){
	return this.reduce(function(sum,x){
		return sum+x.toHTML();
	},"");
};
//mode: 改行の扱い（false:空白同様 true:nullを返す）;
TokenList.prototype.iterate=function(mode){
	var next=null;
	var lit=0;
	//console.log(new TokenList().concat(this));
	while(next=this.shift()){
		lit++;
		this.junk.push(next);
		break;
	}
	this.last_iterate.push(lit);
	//debugger;
	return next;
};
//iterateしたものを戻す
TokenList.prototype.back=function(num){
	if(num===0)num=this.junk.length;
	if(num===null){
		num=this.last_iterate.pop();
		if(!num)num=0;
	}
	for(var i=0;i<num && this.junk.length>0;i++){
		this.unshift(this.junk.pop());
	}
	//console.log("back");
	//console.log(new TokenList().concat(this));
};
//iterateしたものを確定して消す
TokenList.prototype.save=function(){
	this.junk=[];
};
TokenList.prototype.pushes=function(arr){
	if(!(arr instanceof Array)){
		this.pushes([arr]);
		return;
	}
	arr.forEach(function(x){this.push(x)});
	
};
TokenList.prototype.concat=function(){
	var ret=new TokenList(this);
	for(var i=0;i<arguments.length;i++){
		if(arguments[i] instanceof Array){
			arguments[i].forEach(function(x){ret.push(x)});
		}else{
			ret.push(arguments[i]);
		}
	}
	return ret;
	
};
TokenList.prototype.flatten=function(){
	var ret=new TokenList();
	this.forEach(function(x){
		if(x instanceof Array){
			ret=ret.concat(x);
		}else{
			ret.push(x);
		}
	});
	return ret;
}

function LiveTokenList(){
	this.str=null;
	if(typeof arguments[0] ==="string"){
		this.setStr(arguments[0]);
		TokenList.apply(this);
	}else{
		TokenList.apply(this,arguments);
	}
	this.defs=new ParseDefinisions();
	var d=this.defs.defs;
	var r={};	//正規表現リスト
	r.wss=new RegExp("^"+ee(d.WhiteSpace)+"+");//空白
	r.lin=new RegExp("^"+ee(d.LineTerminator)+"+");//改行
	r.com=new RegExp("^"+ee(d.Comment));	//コメント
	r.pun=new RegExp("^"+ee(d.Punctuator));	//演算子
	r.lit=new RegExp("^"+ee(d.Literal));	//リテラル（null、真偽値、数値）
	r.stl=new RegExp("^"+ee(d.StringLiteral));//文字列
	r.rgl=new RegExp("^"+ee(d.RegExpLiteral));//正規表現
	r.ide=new RegExp("^"+ee(d.Identifier));	//識別子
	
	r.ide_switch=function(d,v){
		if(d.keywords.indexOf(v)>=0)return new KeywordToken(v);
		if(d.futureReservedWords.indexOf(v)>=0)return new FutureReservedWordToken(v);
		return new IdentifierToken(v);
	};
	/*r.pun_switch=function(mode2,v){
		if(v=="/" || v=="/="){
			if(!mode2)return new UndefinedToken();
		}
		return new PunctuatorToken(v);	
	}*/
	
	this.r=r;
	//regexp用にエスケープ
	function e(str){
		//return str.replace("\\","\\\\");
		return str;
	}
	function ee(reg){
		return e(reg.source);
	}
}
LiveTokenList.prototype=Object.create(TokenList.prototype);
LiveTokenList.prototype.setStr=function(str){
	this.str=str;
};
//mode2: trueなら 除算演算子 / /= を許可
LiveTokenList.prototype.iterate=function(mode,mode2){
	
	//識別子
	var th=this,d=this.defs,r=this.r;
	var ide_switch=r.ide_switch.bind(this,d);
	//var pun_switch=r.pun_switch.bind(this,mode2);
	
	var patterns=[[r.lin,LineTerminatorToken],[r.wss,WhiteSpaceToken],[r.com,CommentToken],
		      [r.lit,LiteralToken],[r.stl,StringLiteralToken],[r.ide,ide_switch]];


	var next=null;
	var lit=0;
	
	mainLoop:while(next=null,this.str || this.length){
		if(this.length==0){
			var result,newtoken=null;
			var mypatterns;
			if(mode2){
				mypatterns=patterns.concat([[r.pun,PunctuatorToken],[r.rgl,RegExpLiteralToken]]);
			}else{
				mypatterns=patterns.concat([[r.rgl,RegExpLiteralToken],[r.pun,PunctuatorToken]]);
			}
			for(var i=0,l=mypatterns.length;i<l;i++){
				if(result=this.str.match(mypatterns[i][0])){
					newtoken=new mypatterns[i][1](result[0]);
					if(newtoken instanceof UndefinedToken)continue;
					newtoken.raw_str=result[0];
					this.push(newtoken);
					this.str=this.str.slice(result[0].length);
					break;
				}
			}
		}
		next=this.shift();
		if(!next)break;
		lit++;
		this.junk.push(next);
		if(next instanceof WhiteSpaceToken)continue;
		if(next instanceof CommentToken)continue;
		if(next instanceof LineTerminatorToken){
			if(mode)break;
			continue;
		}
		break;
	}
	if(!next && (this.str||this.length)){
		throw new SyntaxError();
	}
	this.last_iterate.push(lit);
	return next;
}
//iterateしたものを戻す
LiveTokenList.prototype.back=function(num){
	if(num===0)num=this.junk.length;
	if(num===null){
		num=this.last_iterate.pop();
		if(!num)num=0;
	}
	for(var i=0;i<num && this.junk.length>0;i++){
		var p=this.junk.pop();
		if(!p)break;
		this.str=p.raw_str+this.str;
	}
	//console.log("back");
	//console.log(new TokenList().concat(this));
};

//トークン
function Token(v){
	this.value=v;
	
	this.raw_str=null;	//生の文字列
}
Token.prototype=Object.create(ParseDefinisions.prototype);
Token.prototype.toString=function(){return this.value};
Token.prototype.toHTML=function(){return this.value};
Token.prototype.equal=function(type,value){
	return this instanceof type && this.value==value;
};
Token.prototype.tokenize=function(manager){return new TokenList(this)};

//ダミー
function UndefinedToken(v){
	
}
UndefinedToken.prototype=Object.create(Token.prototype);

function CommentToken(v){
	Token.apply(this,arguments);
}
CommentToken.prototype=Object.create(Token.prototype);
CommentToken.prototype.toHTML=function(){
	return "<span class='token comment'>"+this.value+"</span>";
};

function PunctuatorToken(v){
	Token.apply(this,arguments);
}
PunctuatorToken.prototype=Object.create(Token.prototype);
PunctuatorToken.prototype.toHTML=function(){
	return "<span class='token punctuator'>"+this.value+"</span>";
};
function WhiteSpaceToken(v){
	Token.apply(this,arguments);
}
WhiteSpaceToken.prototype=Object.create(Token.prototype);


function LineTerminatorToken(v){
	Token.apply(this,arguments);
}
LineTerminatorToken.prototype=Object.create(Token.prototype);

function IdentifierToken(v){
	Token.apply(this,arguments);
}
IdentifierToken.prototype=Object.create(Token.prototype);
IdentifierToken.prototype.toHTML=function(){
	return "<span class='token identifier'>"+this.value+"</span>";
};

function LiteralToken(v){
	Token.apply(this,arguments);
}
LiteralToken.prototype=Object.create(Token.prototype);
LiteralToken.prototype.toHTML=function(){
	return "<span class='token literal'>"+this.value+"</span>";
};

function StringLiteralToken(v){
	LiteralToken.apply(this,arguments);
}
StringLiteralToken.prototype=Object.create(LiteralToken.prototype);
StringLiteralToken.prototype.toHTML=function(){
	return "<span class='token literal string'>"+this.value+"</span>";
};

function RegExpLiteralToken(v){
	LiteralToken.apply(this,arguments);
}
RegExpLiteralToken.prototype=Object.create(LiteralToken.prototype);
RegExpLiteralToken.prototype.toHTML=function(){
	return "<span class='token literal regexp'>"+this.value+"</span>";
};
function KeywordToken(v){
	Token.apply(this,arguments);
}
KeywordToken.prototype=Object.create(Token.prototype);
KeywordToken.prototype.toHTML=function(){
	return "<span class='token keyword'>"+this.value+"</span>";
};
KeywordToken.prototype.tokenize=function(manager){
	var ret=new TokenList(this);
	if(this.value=="new"){
		ret.push(manager.just());
	}
	return ret;
};
function FutureReservedWordToken(v){
	Token.apply(this,arguments);
}
FutureReservedWordToken.prototype=Object.create(Token.prototype);
FutureReservedWordToken.prototype.toHTML=function(){
	return "<span class='token futurereservedword'>"+this.value+"</span>";
};
//-----------------------------------------

function Statements(){
	Array.apply(this,arguments);
}
Statements.prototype=Object.create(Array.prototype);
Statements.prototype.tokenize=function(manager){
	var ret=new TokenList();
	this.forEach(function(x){ret=ret.concat(x.tokenize(manager))});
	
	return ret;
}

function SourceElements(){
	Statements.apply(this,arguments);
}
SourceElements.prototype=Object.create(Statements.prototype);

function FunctionDeclaration(){
	this.name=null;	//Identifier
	this.paramlist=null;	//[Identifier]
	this.functionbody=null;	//SourceElements
	this.returnType=null;	//独自拡張(string)
}
FunctionDeclaration.prototype.tokenize=function(manager){
	var ret=new TokenList(
		new KeywordToken("function")
	);
	if(this.name){
		ret.push(manager.just());
		ret.push(this.name);
	}
	ret.push(
		new PunctuatorToken("(")
	);
	ret=ret.concat(this.paramlist);
	ret.push(new PunctuatorToken(")"));
	//独自拡張
	if(this.returnType){
		ret.push(
			new PunctuaterToken(":"),
			new IdentifierToken(this.returnType)
		);
	}
	ret.push(
		new PunctuatorToken("{"),
		manager.newline()
	);
	ret=ret.concat(manager.indent(this.functionbody.tokenize(manager)));
	ret.push(
		new PunctuatorToken("}"),
		manager.newline()
	);
	return ret;
}
function FunctionExpression(){
	FunctionDeclaration.apply(this);
}
FunctionExpression.prototype=Object.create(FunctionDeclaration.prototype);
FunctionExpression.prototype.tokenize=function(manager){
	var ret=new TokenList(
		new KeywordToken("function")
	);
	if(this.name){
		ret.push(manager.just());
		ret.push(this.name);
	}
	ret.push(
		new PunctuatorToken("(")
	);
	ret=ret.concat(this.paramlist);
	ret.push(
		new PunctuatorToken(")"),
		new PunctuatorToken("{"),
		manager.newline()
	);
	ret=ret.concat(manager.indent(this.functionbody.tokenize(manager)));
	ret.push(
		new PunctuatorToken("}")
	);
	return ret;
}


//関数呼び出しの引数リスト ()付き
//Token,Expression
function Arguments(){
	Array.apply(this,arguments);
}
Arguments.prototype=Object.create(Array.prototype);
Arguments.prototype.tokenize=function(manager){
	var ret=new TokenList(new PunctuatorToken("("));
	var ret2=new TokenList();
	this.forEach(function(x){
		ret2=ret2.concat(x.tokenize(manager));
	});
	ret=ret.concat(new TokenList(Joinarr(this.map(function(x){return x.tokenize(manager)}),new PunctuatorToken(","))).flatten());
	ret.push(new PunctuatorToken(")"));
	return ret;
}

function Statement(){
	
}
function BlockStatement(){
	this.statements=new Statements();
}
BlockStatement.prototype=Object.create(Statement.prototype);
BlockStatement.prototype.tokenize=function(manager){
	return new TokenList(new PunctuatorToken("{"),manager.newline()).concat(manager.indent(this.statements.tokenize(manager)))
			     .concat([new PunctuatorToken("}"),manager.newline()]);
}
function VariableStatement(){
	this.variables=[];
	//[Identifier,AssignmentExpression] ( Identifier = AssignmentExpression)
}
VariableStatement.prototype=Object.create(Statement.prototype);
VariableStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("var"),manager.just());
	this.variables.forEach(function(x,i){
		if(i>0)ret.push(new PunctuatorToken(","));
		ret.push(x[0]);
		if(x[1])ret.push(new PunctuatorToken("=")),ret=ret.concat(x[1].tokenize(manager));
	});
	ret.push(new PunctuatorToken(";"),manager.newline());
	return ret;
}

function EmptyStatement(){
}
EmptyStatement.prototype=Object.create(Statement.prototype);
EmptyStatement.prototype.tokenize=function(manager){
	return new TokenList(new PunctuatorToken(";"),manager.newline());
}

function ExpressionStatement(){
	this.exp=null;	//Expression
}
ExpressionStatement.prototype=Object.create(Statement.prototype);
ExpressionStatement.prototype.tokenize=function(manager){
	return this.exp.tokenize(manager).concat([new PunctuatorToken(";"),manager.newline()]);
}

function IfStatement(){
	this.condition=null;	//Expression 条件
	this.truestatement=null;//真のときのステートメント
	this.elsestatement=null;//elseのステートメント（nullならelseはない）
}
IfStatement.prototype=Object.create(Statement.prototype);
IfStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("if"),new PunctuatorToken("("));
	ret=ret.concat(this.condition.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.truestatement.tokenize(manager));
	if(this.elsestatement){
		if(this.truestatement instanceof BlockStatement){
			manager.chomp(ret);
		}
		ret.push(new KeywordToken("else"));
		ret=ret.concat(manager.split(this.elsestatement.tokenize(manager)));
	}
	return ret;
}

function IterationStatement(){
	
}
IterationStatement.prototype=Object.create(Statement.prototype);
function Do_WhileStatement(){
	this.condition=null;	//Expression 条件
	this.statement=null;	//Statement
}
Do_WhileStatement.prototype=Object.create(IterationStatement.prototype);
Do_WhileStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("do"));
	ret=ret.concat(manager.split(this.statement.tokenize(manager)));
	ret.push(new KeywordToken("while"),new PunctuatorToken("("));
	ret=ret.concat(this.condition.tokenize(manager));
	ret.push(new PunctuatorToken(")"),new PunctuatorToken(";"),manager.newline());
	return ret;
	
}
function WhileStatement(){
	this.condition=null;	//Expression 条件
	this.statement=null;	//Statement
}
WhileStatement.prototype=Object.create(IterationStatement.prototype);
WhileStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("while"),new PunctuatorToken("("));
	ret=ret.concat(this.condition.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.statement.tokenize(manager));
	return ret;
	
}

function ForStatement(){
	this.exp1=null,this.exp2=null,this.exp3=null;	//Expression
	this.statement=null;	//Statement
}
ForStatement.prototype=Object.create(IterationStatement.prototype);
ForStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("for"),new PunctuatorToken("("));
	if(this.exp1)ret=ret.concat(this.exp1.tokenize(manager));
	ret.push(new PunctuatorToken(";"));
	if(this.exp2)ret=ret.concat(this.exp2.tokenize(manager));
	ret.push(new PunctuatorToken(";"));
	if(this.exp3)ret=ret.concat(this.exp3.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.statement.tokenize(manager));
	return ret;
}

function For_VarStatement(){
	this.variables=[];//VariableStatementと同じ
	this.exp2=null,this.exp3=null;
	this.statement=null;	//Statement
}
For_VarStatement.prototype=Object.create(IterationStatement.prototype);
For_VarStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("for"),new PunctuatorToken("("),new KeywordToken("var"),manager.just());
	this.variables.forEach(function(x,i){
		if(i>0)ret.push(new PunctuatorToken(","));
		ret.push(x[0]);
		if(x[1])ret.push(new PunctuatorToken("=")),ret=ret.concat(x[1].tokenize(manager));
	});
	ret.push(new PunctuatorToken(";"));
	if(this.exp2)ret=ret.concat(this.exp2.tokenize(manager));
	ret.push(new PunctuatorToken(";"));
	if(this.exp3)ret=ret.concat(this.exp3.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.statement.tokenize(manager));
	return ret;
}

function For_InStatement(){
	this.exp1=null,this.exp2=null;	//exp1 in exp2
	this.statement=null;	//Statement
}
For_InStatement.prototype=Object.create(IterationStatement.prototype);
For_InStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("for"),new PunctuatorToken("("));
	ret=ret.concat(this.exp1.tokenize(manager));
	ret.push(manager.just(),new KeywordToken("in"),manager.just());
	ret=ret.concat(this.exp2.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.statement.tokenize(manager));
	return ret;
}


function For_In_VarStatement(){
	this.variables=null;
	this.exp2=null;	//inの右
	this.statement=null;	//Statement
}
For_In_VarStatement.prototype=Object.create(IterationStatement.prototype);
For_In_VarStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("for"),new PunctuatorToken("("),new KeywordToken("var"),manager.just());
	this.variables.forEach(function(x,i){
		if(i>0)ret.push(new PunctuatorToken(","));
		ret.push(x[0]);
		if(x[1])ret.push(new PunctuatorToken("=")),ret=ret.concat(x[1].tokenize(manager));
	});
	ret.push(manager.just(),new KeywordToken("in"),manager.just());
	ret=ret.concat(this.exp2.tokenize(manager));
	ret.push(new PunctuatorToken(")"));
	ret=ret.concat(this.statement.tokenize(manager));
	return ret;
}

function ContinueStatement(){
	this.identifier=null;
}
ContinueStatement.prototype=Object.create(Statement.prototype);
ContinueStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("continue"));
	if(this.identifier){
		ret.push(manager.just(),this.identifier);
	}
	ret.push(new PunctuatorToken(";"),manager.newline());
	return ret;
}

function BreakStatement(){
	this.identifier=null;
}
BreakStatement.prototype=Object.create(Statement.prototype);
BreakStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("break"));
	if(this.identifier){
		ret.push(manager.just(),this.identifier);
	}
	ret.push(new PunctuatorToken(";"),manager.newline());
	return ret;
}

function ReturnStatement(){
	this.exp=null;
}
ReturnStatement.prototype=Object.create(Statement.prototype);
ReturnStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("return"));
	if(this.exp){
		ret.push(manager.just());
		ret=ret.concat(this.exp.tokenize(manager));
	}
	ret.push(new PunctuatorToken(";"),manager.newline());
	return ret;
}

function WithStatement(){
	this.exp=null;
	this.statement=null;
}
WithStatement.prototype=Object.create(Statement.prototype);
WithStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("with"),new PunctuatorToken("("));
	ret=ret.concat(this.exp.tokenize(manager)).concat(new PunctuatorToken(")")).concat(this.statement.tokenize(manager));
	return ret;
}

function SwitchStatement(){
	this.exp=null;
	this.cases=[];
	//[Expression,Statements, mode] //modeがtrue→Expressionはnull.default
}
SwitchStatement.prototype=Object.create(Statement.prototype);
SwitchStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("switch"),new PunctuatorToken("("));
	ret=ret.concat(this.exp.tokenize(manager));
	ret.push(new PunctuatorToken(")"),new PunctuatorToken("{"),manager.newline());
	this.cases.forEach(function(x){
		if(x[2]){
			//default
			ret.push(new KeywordToken("default"),new PunctuatorToken(":"),manager.newline());
			ret=ret.concat(manager.indent(x[1].tokenize(manager)));
		}else{
			ret.push(new KeywordToken("case"),manager.just());
			ret=ret.concat(x[0].tokenize(manager));
			ret.push(new PunctuatorToken(":"),manager.newline());
			ret=ret.concat(manager.indent(x[1].tokenize(manager)));
		}
	});
	ret.push(new PunctuatorToken("}"),manager.newline());
	return ret;
}

function LabelledStatement(){
	this.identifier=null;
	this.statement=null;
}
LabelledStatement.prototype=Object.create(Statement.prototype);
LabelledStatement.prototype.tokenize=function(manager){
	return new TokenList([this.identifier,new PunctuatorToken(":"),manager.just()].concat(this.statement.tokenize(manager)));
}

function ThrowStatement(){
	this.exp=null;
}
ThrowStatement.prototype=Object.create(Statement.prototype);
ThrowStatement.prototype.tokenize=function(manager){
	return new TokenList([new KeywordToken("throw"),manager.just()].concat(this.exp.tokenize(manager)));
}

function TryStatement(){
	this.block=null;	//BlockStatement
	this.catchidentifier=null;	//Identifier
	this.catchblock=null;	//BlockStatement / null
	this.finallyblock=null;	//BlockStatement / null
}
TryStatement.prototype=Object.create(Statement.prototype);
TryStatement.prototype.tokenize=function(manager){
	var ret=new TokenList(new KeywordToken("try"));
	ret=ret.concat(manager.split(this.block.tokenize(manager)));
	if(this.catchblock){
		ret.push(new KeywordToken("catch"),new PunctuatorToken("("),this.catchidentifier,new PunctuatorToken(")"));
		ret=ret.concat(this.catchblock.tokenize(manager));
	}
	if(this.finallyblock){
		ret.push(new KeywordToken("finally"));
		ret=ret.concat(manager.split(this.finallyblock.tokenize(manager)));
	}
	return ret;
}

function DebuggerStatement(){
}
DebuggerStatement.prototype=Object.create(Statement.prototype);
DebuggerStatement.prototype.tokenize=function(manager){
	return new TokenList(new KeywordToken("debugger"),new PunctuatorToken(";"));
}

function Joinarr(tokens,sep){
	var ret=new TokenList();
	var sep=sep instanceof Function? sep() : sep;
	tokens.forEach(function(x,i){
		if(i!=0){
			if(sep instanceof Array)ret=ret.concat(sep);
			else ret.push(sep);
		}
		ret.push(x);
	});
	return ret;
}

//-----------------------------------------------------
//演算子式
function Expression(){
	//Expression,Tokenからなる
	this.parts=[];
}
Expression.prototype.tokenize=function(manager){
	var ret=new TokenList();
	this.parts.forEach(function(x){
		if(x.tokenize){
			ret=ret.concat(x.tokenize(manager));
		}else{
			ret.push(x);
		}
	});
	return ret;
}
function ArrayLiteral(){
	Expression.apply(this,arguments);
	//partsには各ExpressionとToken , を代入
}
ArrayLiteral.prototype=Object.create(Expression.prototype);
ArrayLiteral.prototype.tokenize=function(manager){
	return new TokenList([new PunctuatorToken("[")]
			     .concat(Expression.prototype.tokenize.call(this,manager))
			     .concat(new PunctuatorToken("]")));
}
function ObjectLiteral(){
	Expression.apply(this,arguments);
	this.properties=[];
	//[名前リテラルなど , 式, フラグ 偽/"get"/"set"]
	//get/setの場合、式はFunctionDeclartion
}
ObjectLiteral.prototype=Object.create(Expression.prototype);
ObjectLiteral.prototype.tokenize=function(manager){
	var ret=new TokenList(new PunctuatorToken("{"),manager.newline());
	if(this.properties.length>0){
		ret=ret.concat(manager.indent(this.properties.map(function(x){
			if(x[2]){
				var ret2=x[1].tokenize(manager);
				ret2.shift();	//function を取り除く
				ret2.unshift(new KeywordToken(x[2]));
				return ret2;
			}
			return [x[0],new PunctuatorToken(":"),].concat(x[1].tokenize(manager));
		}).reduce(function(p,c){
			return p.concat([new PunctuatorToken(","),manager.newline()]).concat(c);
		})));
	}
	ret=ret.concat([manager.newline(),new PunctuatorToken("}")]);
	return ret;
}
 
//--- トークナイズ用マネージャ
function TokenizeManager(){
}
TokenizeManager.prototype.just=function(){
	return new WhiteSpaceToken(" ");
};
TokenizeManager.prototype.split=function(tokenlist){
	//最初がIdentifierならスペースを入れないとだめ
	var first=tokenlist[0];
	if((first instanceof IdentifierToken)||(first instanceof LiteralToken)||(first instanceof KeywordToken)||(first instanceof FutureReservedWordToken)){
		tokenlist.unshift(this.just());
	}
	return tokenlist;
};
TokenizeManager.prototype.indent=function(tokenlist){
	var ret=new TokenList();
	var flg=true;
	tokenlist.forEach(function(x){
		if(flg)ret.push(new WhiteSpaceToken("\t")),flg=false;
		if(x instanceof LineTerminatorToken)flg=true;
		ret.push(x);
	});
	return ret;
};
TokenizeManager.prototype.chomp=function(tokenlist){
	//末尾改行を取り除く
	for(var i=tokenlist.length-1;i>=0;i--){
		if(tokenlist[i] instanceof LineTerminatorToken){
			tokenlist.pop();
		}else{
			break;
		}
	}
	return tokenlist;
};
TokenizeManager.prototype.newline=function(){
	return new LineTerminatorToken("\n");
};
TokenizeManager.prototype.tokenize=function(obj){
	return obj.tokenize(this);
};
//
//エクスポーーーーーーート
exports.JSParser=JSParser;
exports.TokenizeManager=TokenizeManager;
//もっとエクスポーーーーーート
exports.Token=Token;
exports.UndefinedToken=UndefinedToken;
exports.CommentToken=CommentToken;
exports.PunctuatorToken=PunctuatorToken;
exports.WhiteSpaceToken=WhiteSpaceToken;
exports.LineTerminatorToken=LineTerminatorToken;
exports.IdentifierToken=IdentifierToken;
exports.LiteralToken=LiteralToken;
exports.StringLiteralToken=StringLiteralToken;
exports.RegExpLiteralToken=RegExpLiteralToken;
exports.KeywordToken=KeywordToken;
exports.FutureReservedWordToken=FutureReservedWordToken;

exports.Statements=Statements;
exports.SourceElements=SourceElements;
exports.FunctionDeclaration=FunctionDeclaration;
exports.FunctionExpression=FunctionExpression;
exports.Arguments=Arguments;
exports.Statement=Statement;
exports.BlockStatement=BlockStatement;
exports.VariableStatement=VariableStatement;
exports.EmptyStatement=EmptyStatement;
exports.ExpressionStatement=ExpressionStatement;
exports.IfStatement=IfStatement;
exports.IterationStatement=IterationStatement;
exports.Do_WhileStatement=Do_WhileStatement;
exports.WhileStatement=WhileStatement;
exports.ForStatement=ForStatement;
exports.For_VarStatement=For_VarStatement;
exports.For_InStatement=For_InStatement;
exports.For_In_VarStatement=For_In_VarStatement;
exports.ContinueStatement=ContinueStatement;
exports.BreakStatement=BreakStatement;
exports.ReturnStatement=ReturnStatement;
exports.WithStatement=WithStatement;
exports.SwitchStatement=SwitchStatement;
exports.LabelledStatement=LabelledStatement;
exports.ThrowStatement=ThrowStatement;
exports.TryStatement=TryStatement;
exports.DebuggerStatement=DebuggerStatement;

exports.Expression=Expression;
exports.ArrayLiteral=ArrayLiteral;
exports.ObjectLiteral=ObjectLiteral;
exports.Arguments=Arguments;
