# template-resolver
[![Build Status](https://travis-ci.org/danielkalen/template-resolver.svg?branch=master)](https://travis-ci.org/danielkalen/template-resolver)
[![Code Climate](https://codeclimate.com/github/danielkalen/template-resolver/badges/gpa.svg)](https://codeclimate.com/github/danielkalen/template-resolver)
[![NPM](https://img.shields.io/npm/v/template-resolver.svg)](https://npmjs.com/package/template-resolver)

Resolves env variables & inline shell commands in static files.
Features:
- Resolves env variables in files in the form of `${ENV_VAR}`
- Runs inline shell commands in files in the form of `$(command)`
- Runs inline shell commands in files in the form of `` `command` ``

## Usage
#### Command Line
Use the command `template-resolver` or `tmpl`.
```
cat myfile.tmpl | template-resolver > result.txt
```

```
echo 'current env is ${NODE_ENV}' | tmpl
current env is development

echo 'our system arch is `uname -p`' | tmpl
current env is i386

echo 'our system name is $(uname -s)' | tmpl
current env is Darwin
```


#### Node API
```
var resolver = require('template-resolver');
var content = 'our system is "$(uname -s) `uname -p`" under ${NODE_ENV} env';

resolver(content).then((result)=> {
    result //= our system is "Darwin i386" under development env
});
```


## License
MIT © [Daniel Kalen](https://github.com/danielkalen)