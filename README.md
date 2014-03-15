PythonToAST
===========

Javascript-based parser that translates Python code to the Mozilla abstract syntax tree [AST](https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API) format

[PEG.js](http://pegjs.majda.cz/) is used to generate the parser from a Python pegjs-style grammer definition

[escodegen](http://github.com/Constellation/escodegen) is used to generate Javascript from the AST

Create parser: 

  1. pegjs python33.pegjs build\parser.js

Testing parser:
  
  1. node test\test.js

Testing end-to-end in browser:

  1. browserify -r ./build/parser.js -o ./build/bundle.js
  2. Nav to index.html
