String.prototype.base26ToAlpha = ->
	base26Str = this
	aCode = 'a'.charCodeAt(0)
	pCode = 'p'.charCodeAt(0)
	_0Code = '0'.charCodeAt(0)
	_9Code = '9'.charCodeAt(0)
	result = _.map(base26Str, (c) ->
		code = c.charCodeAt(0)
		if code >= aCode and code <= pCode
			code += 10
		else if code >= _0Code and code <= _9Code
			code = aCode + code - _0Code
		else
			throw "Invalid base26Str: '#{base26Str}'"
		return String.fromCharCode(code)
	).join('')
	return result

String.prototype.base26FromAlpha = ->
	alphaStr = this
	aCode = 'a'.charCodeAt(0)
	jCode = 'j'.charCodeAt(0)
	zCode = 'z'.charCodeAt(0)
	_0Code = '0'.charCodeAt(0)
	result = _.map(alphaStr, (c) ->
		code = c.charCodeAt(0)
		if code > jCode and code <= zCode
			code -= 10
		else if code >= aCode and code <= jCode
			code = _0Code + code - aCode
		else
			throw "Invalid alphaStr: '#{alphaStr}'"
		return String.fromCharCode(code)
	).join('')
	return result
