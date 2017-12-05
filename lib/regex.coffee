exports.commandTicks = /\`(.+?)\`/g
exports.commandDollar = /\$\((.+?)\)/g
exports.envVar = /\$\{(.+?)\}/g
exports.jsEnvVar = /\$(\w+)/g
exports.jsExpression = ///
	\{\{
	([\w\W]+?)
	\}\}
///g

