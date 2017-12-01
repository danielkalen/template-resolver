stringReplace = require 'string-replace-async'
execa = require 'execa'
regex = require './regex'
require('mountenv').load()

resolveTemplate = (content)->
	Promise.resolve(content)
		.then (content)-> content.replace regex.envVar, replaceEnvVar
		.then (content)-> stringReplace content, regex.commandTicks, replaceCommand
		.then (content)-> stringReplace content, regex.commandDollar, replaceCommand


replaceCommand = (e,command)->
	execa.shell(command).then (result)-> result.stdout

replaceEnvVar = (e,target)->
	process.env[target] or ''

module.exports = resolveTemplate