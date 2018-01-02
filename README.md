# template-resolver
[![Build Status](https://travis-ci.org/danielkalen/template-resolver.svg?branch=master)](https://travis-ci.org/danielkalen/template-resolver)
[![Code Climate](https://api.codeclimate.com/v1/badges/ff8e12dbabe5bf454825/maintainability)](https://codeclimate.com/github/danielkalen/template-resolver)
[![NPM](https://img.shields.io/npm/v/template-resolver.svg)](https://npmjs.com/package/template-resolver)

Resolves env variables & inline shell commands in static files.
Features:
- Resolves env variables in files in the form of `${ENV_VAR}`
- Runs inline shell commands in files in the form of `$(command)`
- Runs inline shell commands in files in the form of `` `command` ``
- Resolves & inlines imports in the form of `import './child'`

## Usage
#### Command Line
Use the command `template-resolver` or `tmpl`.
```bash
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
```javascript
var resolver = require('template-resolver');
var content = 'our system is "$(uname -s) `uname -p`" under ${NODE_ENV} env';

resolver(content).then((result)=> {
    result //= our system is "Darwin i386" under development env
});
```

## Imports
Any import statements encountered in a file will be recursivly inlined inside the importing file. By default import paths will be resolved relative to the `CWD` but can be specified via the `-c dir` cli argument or as the second argument passed to the node API.

**Example**
```
└─ dir/main
   ├─ dir/children/one
   └─ dir/children/two
```
*./dir/main*
```
this is main file and these are my children:
    import './children/one'
    import './children/two'
```

**Command Line**
```bash
cat ./dir/main | template-resolver -c ./dir
```

**Node API**
```javascript
resolver(content, './dir')
```



## License
MIT © [Daniel Kalen](https://github.com/danielkalen)