@CollectionUtils =
	fixKeysForMongo: (doc) ->
		if doc instanceof Object
			for k, v of doc
				if k.match(/\.|^\$/) # forbidden keys: https://jira.mongodb.org/browse/SERVER-3229
					fixedKey = k.replace(/\./g, '•').replace(/^\$/, '฿')
					doc[fixedKey] ?= v # do not overwrite another existing key
					delete doc[k]
					CollectionUtils.fixKeysForMongo(doc[fixedKey])
				else
					CollectionUtils.fixKeysForMongo(v)
		else if doc instanceof Array
			for e in doc
				CollectionUtils.fixKeysForMongo(e)
		return doc
