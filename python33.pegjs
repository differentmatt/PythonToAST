// TODO: input src must end with a newline
// TODO: can't have whitespace in front of anything.  don't forget indent!
// PROBLEM: indenting
// PROBLEM: variable declaration
{
	var gVariables = {};
}

start
	= WHITESPACE left:(NEWLINE / stmt) WHITESPACE right:(NEWLINE / stmt) { return {type:'Program', body:[left, right]}; }
	/ WHITESPACE left:(NEWLINE / stmt) { return {type:'Program', body:[left]}; }

funcdef "funcdef"
	= 'def' WHITESPACE id:NAME WHITESPACE params:parameters WHITESPACE ':' WHITESPACE body:suite { return {type:'FunctionDeclaration', id:id, params:params, body:body}; }
	
parameters "parameters"
	= '(' ')' { return []; }
	/ '(' left:typedargslist ')' { return left; }

typedargslist "typedargslist"
	= left:tfpdef WHITESPACE right:(',' WHITESPACE tfpdef)* 
		{ 
			if (right.length == 0) { 
				return [left]; 
			} 
			else { 
				var ret = [left];
				for (var i = 0; i < right.length; i++) {
					ret.push(right[i][2]);
				}
				return ret; 
			} 
		}
	
tfpdef "tfpdef"
	= left:NAME { return left; }
	
stmt "stmt" // TODO: can't reset variables here.  must deal with scope!
	= left:simple_stmt { gVariables = {}; return left; }
	/ left:compound_stmt { return left; }
	
simple_stmt "simple_stmt"
	= left:small_stmt WHITESPACE NEWLINE { return left; }
	
small_stmt "small_stmt"
	= left:flow_stmt { return left; }
	/ left:expr_stmt { return left; }
	
expr_stmt "expr_stmt"
	= left:testlist_star_expr WHITESPACE right:(WHITESPACE '=' WHITESPACE testlist_star_expr)* 
		{
			if (right.length == 0) {
				return { type:'ExpressionStatement', expression:left };
			}
			else {
				var ret = right[right.length - 1][3];
				for (var i = right.length - 2; i >= 0; i--) {
					ret = { type:'AssignmentExpression', operator:'=', left:right[i][3], right:ret };
				}
				if (gVariables.hasOwnProperty(left.name)) {
					ret = { type:'AssignmentExpression', operator:'=', left:left, right:ret };
				}
				else {
					ret = { 
						type:'VariableDeclaration', 
						declarations: [
						{
							type:'VariableDeclarator',
							id:left,
							init:ret
						}],
						kind:'var'
					};
					gVariables[left.name] = true;
				}
				return ret;
			}
		}
	
testlist_star_expr "testlist_star_expr"
	= left:test { return left; }

flow_stmt "flow_stmt"
	= left:(return_stmt) { return left; }
	
return_stmt "return_stmt"
	= 'return' WHITESPACE left:(testlist?) { return {type:'ReturnStatement', argument:left}; }

compound_stmt
	= left:(if_stmt / funcdef) { return left; }

if_stmt
	//= 'if' test:test ':' consequent:suite alternate:('else' ':' suite)? { return {type:'IfStatement', test:test, consequent:consequent, altnernate:alternate}; }
	= 'if' WHITESPACE test:test WHITESPACE ':' WHITESPACE consequent:suite { return {type:'IfStatement', test:test, consequent:consequent}; }

suite "suite"
	= NEWLINE left:(INDENT stmt)+ 
		{ 
			var stmts = [];
			for (var i = 0; i < left.length; i++) {
				stmts.push(left[i][1]);
			}
			return {type:'BlockStatement', body:stmts}; 
		}
	/ left:simple_stmt { return left; }

test "test"
	= left:or_test { return left; }
	
or_test
	= left:and_test { return left; }
	
and_test
	= left:not_test { return left; }

not_test
	= left:comparison { return left; }
	
comparison "comparison" // not supporting expr (comp_op expr)* statements like if 4 > 3 > 2: print('python is weird')
	= left:expr WHITESPACE operator:comp_op WHITESPACE right:expr { return {type:'BinaryExpression', left:left, operator:operator, right:right}; }
	/ left:expr { return left; }

comp_op "comp_op"
	= left:('<' / '>' / '==' / '>=' / '<=' / '<>' / '!=' / 'in' / 'not' 'in' / 'is' / 'is' 'not') { return left; }

expr
	= left:xor_expr { return left; }
	
xor_expr
	= left:and_expr { return left; }
	
and_expr
	= left:shift_expr { return left; }
	
shift_expr
	= left:arith_expr { return left; }

arith_expr "arith_expr"
	= left:term WHITESPACE operator:[+\-] WHITESPACE right:term { return {type:"BinaryExpression", left:left, operator:operator, right:right}; }
	/ left:term { return left; }

term
	= left:factor operator:[*/%] right:factor { return {type:"BinaryExpression", left:left, operator:operator, right:right}; }
	/ left:factor operator:"//" right:factor { return {type:"BinaryExpression", left:left, operator:operator, right:right}; }
	/ left:factor { return left; }

factor
	= left:power { return left; }

power
	= left:atom WHITESPACE right:trailer { return {type:'CallExpression', callee:left, arguments:right}; }
	/ left:atom { return left; }
	
atom "atom"
	= '(' left:testlist_comp ')' { return left; }
	/ left:NAME { return left; }
  / left:NUMBER { return left; }
	/ left:STRING { return left; }

testlist_comp
	= left:test { return left; }

trailer "trailer" // grammar has array here, but we build it in arglist instead
	= '(' arguments:arglist? ')' { return arguments; }

testlist
	= left:test right:(',' test)* { if (right.length == 0) { return left; } else { right.unshift(left); return right; } }

arglist
	= left:(argument WHITESPACE ',')* WHITESPACE right:argument 
		{
			var ret = [right];
			for (var i = 0; i < left.length; i++) {
				ret.unshift(left[i][0]);
			}
			return ret; 
		}
	
argument
	= left:test { return left; }

INDENT "INDENT" // TODO: will need to do some voodoo regarding indentation
	= "  " / "\t"

NAME	// TODO: support richer names
	= left:[a-zA-Z]+ { return {type:'Identifier', name:left.join("")}; }

NEWLINE "NEWLINE"
	= '\n' / '\r\n'

NUMBER
	= digits:[0-9]+ { return {type:'Literal', value:parseInt(digits.join(""), 10)}; }

STRING
	= "\'" left:([^\'])* "\'" { return {type:'Literal', value:left.join("")}; }
	/ '\"' left:([^\"])* '\"' { return {type:'Literal', value:left.join("")}; }
	
WHITESPACE "WHITESPACE"
	= [ \t]*