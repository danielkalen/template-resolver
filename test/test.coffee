chai = require 'chai'
chai.use require 'chai-as-promised'
{expect} = chai


suite "template-resolver", ()->
	test "exports a function that accepts string as input and returns string as output", ()->
		Promise.resolve()
			.then ()-> require('../')('abc123')
			.then (result)-> expect(result).to.equal 'abc123'


	test "will resolve env variables in syntax of ${VAR}", ()->
		process.env.ABC = 123
		process.env.DEF = 456
		
		Promise.resolve()
			.then ()-> require('../')('abc-${ABC}:def-${DEF}')
			.then (result)-> expect(result).to.equal 'abc-123:def-456'


	test "empty env variables will be replaced with an empty string", ()->
		delete process.env.ABC
		process.env.DEF = 456
		
		Promise.resolve()
			.then ()-> require('../')('abc-${ABC}:def-${DEF}')
			.then (result)-> expect(result).to.equal 'abc-:def-456'


	test "strings in backticks will be replaced as shell scripts", ()->
		process.env.ABC = 123
		delete process.env.DEF
		
		Promise.resolve()
			.then ()-> require('../')('abc-${ABC}:def-`export DEF=444 && echo $DEF`:ghi-789')
			.then (result)-> expect(result).to.equal 'abc-123:def-444:ghi-789'


	test "strings in $(...) will be replaced as shell scripts", ()->
		expected = null
		
		Promise.resolve()
			.then ()-> require('execa').stdout 'whoami'
			.then (whoami)-> expected = whoami
			.then ()-> require('../')('I am $(whoami)!')
			.then (result)-> expect(result).to.equal "I am #{expected}!"


	test "strings in {{...}} will be replaced as js expressions", ()->		
		Promise.resolve()
			.then ()-> require('../')('I am {{typeof abc === "undefined" ? 123 : 456}}!')
			.then (result)-> expect(result).to.equal "I am 123!"

	
	test "env variables can be referenced via $ENV_VAR syntax", ()->
		script = 'I am {{typeof $AAA === "undefined" ? 123 : 456}}!'
		Promise.resolve()
			.then ()-> require('../')(script)
			.then (result)-> expect(result).to.equal "I am 123!"
			.then ()-> process.env.AAA=0; require('../')(script)
			.then (result)-> expect(result).to.equal "I am 456!"


	test "env variables will be resolved before shell commands", ()->
		process.env.TARGET = 'uname'
		expected = null
		
		Promise.resolve()
			.then ()-> require('execa').stdout process.env.TARGET, ['-v']
			.then (uname)-> expected = uname
			.then ()-> require('../')('I am $(${TARGET} -v)!')
			.then (result)-> expect(result).to.equal "I am #{expected}!"


	test "bin version accepts input via stdin and returns result via stdout", ()->
		content = 'The result for `echo $TARGET` is $(${TARGET} -v).'
		process.env.TARGET = 'uname'
		uname = null
		
		Promise.resolve()
			.then ()-> require('execa').stdout process.env.TARGET, ['-v']
			.then (result)-> uname = result
			.then ()-> runCLI(content)
			.then (result)->
				expect(result.stderr).to.equal ''
				expect(result.stdout).to.equal "The result for uname is #{uname}."


	suite "imports", ()->
		fs = require 'fs-jetpack'
		suiteTeardown ()-> fs.remove './temp'
		suiteSetup ()->
			process.env.AAA = 1
			process.env.BBB = 2
			process.env.CCC = 3
			process.env.EXCL = '!'
			fs.dir './temp', empty:true
			fs.write './temp/main', @mainContent = """
				my env is ${NODE_ENV}import './excl'
				  import './child'
			"""
			fs.write './temp/excl', """
				${EXCL}${EXCL}${EXCL}
			"""
			fs.write './temp/child', """
				I am child${AAA}
				and these are my children:
				  import './child.d/child2'
			"""
			fs.write './temp/child.d/child2', """
				I am child${BBB}
				and these are my children:
				  import './child.d/child3'
			"""
			fs.write './temp/child.d/child.d/child3', """
				I am child${CCC}
				and I dont have any children import '../../excl'
			"""
			@expected = """
				my env is #{process.env.NODE_ENV}!!!
				  I am child1
				  and these are my children:
				    I am child2
				    and these are my children:
				      I am child3
				      and I dont have any children !!!
			"""
		

		test "will be replaced & indented with the imported file's content", ()->
			Promise.resolve()
				.then ()=> require('../')(@mainContent, './temp')
				.then (result)=> expect(result).to.equal @expected

		test "context can be supplied via '-c' cli argument", ()->
			expect(runCLI @mainContent).to.be.rejectedWith Error, 'ENOENT'

			promise = runCLI @mainContent, ['-c', './temp']
			expect(promise).not.to.be.rejected
			promise.then ({stdout})=>
				expect(stdout).to.equal @expected







runCLI = (content, args=[])->
	task = require('execa') './bin', args
	task.stdin.write(content)
	task.stdin.end()
	return task







