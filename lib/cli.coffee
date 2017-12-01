buffer = ''
resolver = require './'

process.stdin.on 'data', (chunk)->
	buffer += chunk.toString()

process.stdin.on 'end', ()->
	Promise.resolve(buffer)
		.then require './'
		.then (result)-> process.stdout.write(result)
		.then ()-> process.exit(0)
		.catch (err)-> console.error(err); process.exit(1)



