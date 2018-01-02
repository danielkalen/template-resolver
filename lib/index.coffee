stringReplace = require 'string-replace-async'
vm = require 'vm'
execa = require 'execa'
regex = require './regex'
require('mountenv').load()

resolveTemplate = (content, context)->
	Promise.resolve(content)
		.then (content)-> content.replace regex.envVar, replaceEnvVar
		.then (content)-> stringReplace content, regex.commandTicks, replaceCommand
		.then (content)-> stringReplace content, regex.commandDollar, replaceCommand
		.then (content)-> content.replace regex.jsExpression, replaceExpression
		.then (content)-> require('./resolveImports') content, context


replaceEnvVar = (e,target)->
	process.env[target] or ''

replaceCommand = (e,command)->
	execa.shell(command).then (result)-> result.stdout

replaceExpression = (e,expression)->
	expression = expression.replace regex.jsEnvVar, (e, variable)-> "env.#{variable}"
	result = runExpression(expression)
	return if result is undefined then '' else result

runExpression = (expression)->
	(new vm.Script expression)
		.runInNewContext {env:process.env}

module.exports = resolveTemplate