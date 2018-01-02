args = process.argv.slice(2)
index = args.indexOf('-c')
context = args[index+1] if index isnt -1
buffer = ''

process.stdin.on 'data', (chunk)->
	buffer += chunk.toString()

process.stdin.on 'end', ()->
	Promise.resolve()
		.then ()-> require('./')(buffer, context)
		.then (result)-> process.stdout.write(result)
		.then ()-> process.exit(0)
		.catch (err)-> console.error(err); process.exit(1)



