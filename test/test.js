var parser = require('../build/parser.js');

function print(ast) {
	console.log(JSON.stringify(ast, null, 2));
}
function parse(s) {
	try {
		return parser.parse(s);
	}
	catch (e) {
		console.log(e);
		return null;
	}
}
parse('\n');
parse('3\n');
parse('1+2\n');
parse('1 +2\n');
parse('1+ 2\n');
parse('1 + 2\n');
parse('2*3+4\n');
parse('2*(3+4)\n');
parse('\
2*(3+4)\n \
5-6\n');
parse("if 4 > 3: 1 + 2\n");
parse("if 4 > 3: print('bigger')\n");
parse("print('Hello world!')\n");
parse("return\n");
parse("return 1 + 2\n");
parse("a = 3\n");
parse("a = b = 3\n");
parse("x = add(1)\n");
parse("foo(a, b)\n");

parse("def greet(): print('hi')\n");
parse("def greet():\n  print('hi')\n");
parse("def add(a):\n  print(a)\n");
parse("def add(a, b, c):\n  print(a + b)\n");
parse("def foo():\n  return\n");
parse('\
def add(a, b):\n\
  print(a + b)\n');
print(parse('\
def add(a, b):\n\
	r = a + b\n\
	return r\n\
x = add(1, 2)\n'));

// TODO: time to parse actual files!