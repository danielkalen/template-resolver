fs = require 'fs'
Path = require 'path'
stringReplace = require 'string-replace-async'
regex = require './regex'

resolveImports = (content, context)->
	return content if not hasImports(content)
	context ?= process.cwd()
	
	stringReplace content, regex.import, (e, whitespace, path)->
		path = Path.resolve(context, path)
		childContent = fs.readFileSync(path, encoding:'utf8')
		
		Promise.resolve(childContent)
			.then (childContent)-> require('./')(childContent, Path.dirname(path))
			.then (childContent)-> childContent.replace(regex.lineStart, whitespace)


hasImports = (content)->
	result = regex.import.test(content)
	regex.import.lastIndex = 0
	return result


module.exports = resolveImports