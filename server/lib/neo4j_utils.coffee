RESERVED = ['start', 'create', 'set', 'delete', 'foreach', 'match', 'where', 'with'
			'return', 'skip', 'limit', 'order', 'by', 'asc', 'desc', 'on', 'when',
			'case', 'then', 'else', 'drop', 'using', 'merge', 'constraint', 'assert'
			'scan', 'remove', 'union']
INVALID_IDEN = /\W/

@Neo4jUtils =
	# Cypher identifiers
	# Identifier names are case sensitive, and can contain underscores and alphanumeric characters (a-z, 0-9),
	# but must always start with a letter.
	# If other characters are needed, you can quote the identifier using backquote (`) signs.
	nextCypherId: (previousId) ->
		if previousId?
			n = parseInt(previousId.base26FromAlpha(), 26) + 1
			return n.toString(26).base26ToAlpha()
		else
			return 'a'

	escapeCypherValue: (val) ->
		escapedValue = switch typeof val
			when 'boolean' then (if val then 'true' else 'false')
			when 'number' then val
			else '"' + ((''+val).replace /"/g, '\\"') + '"'
		return escapedValue

	escapeCypherIdentifier: (name) ->
		if name.toLowerCase() in RESERVED or INVALID_IDEN.test name
			return '`' + (name.replace '`', '``') + '`'
		else
			return name
