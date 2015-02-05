Meteor.startup ->

	worker = (job, cb) ->
		search = Searches.findOne(_id: job.data.searchId)

		url = job.data.itemLink

		# doc: http://www.alchemyapi.com/api/relation/urls.html
		params =
			url: url
			maxRetrieve: 100
			outputMode: 'json'
			sentiment: false
			keywords: true
			entities: true
			requireEntities: true
			disambiguate: true
			linkedData: true
			coreference: true
			showSourceText: true
			sourceText: 'cleaned_or_raw'

		cache = AlchemyApiUrlgetrelsCache.findOne(params)

		if cache?
			cacheId = cache._id
			response = cache.response
			job.progress 90, 100
			console.log "alchemy request cached: #{url}"
		else
			# Alchemy API uses 1/0 instead of true/false
			alchemyParams = {}
			for k, v of params
				if typeof v is 'boolean'
					alchemyParams[k] = if v then 1 else 0
				else
					alchemyParams[k] = v
			try
				result = HTTP.call('GET', 'http://access.alchemyapi.com/calls/url/URLGetRelations',
					params: _.extend({ apikey: ALCHEMY_API_KEY }, alchemyParams)
				)
				response = CollectionUtils.fixKeysForMongo(result.data)
				job.progress 90, 100
				console.log "extract ok: #{url}"
			catch e
				job.fail "Error from alchemy api: #{e}", { fatal: true }
				return cb()

			cacheId = AlchemyApiUrlgetrelsCache.insert _.extend({ response: response }, params)
			console.log "insert cache ok: #{url}"

		res = Searches.update({ _id: search._id, 'items.link': url },
			$set:
				'items.$._alchemyCacheId': cacheId
				'items.$._alchemyResponse': response
		)
		console.log "update item ok: #{url}"

		# create Neo4J entities/relations
		for rel in response.relations
			continue unless rel.subject? and rel.object? # TODO: log warning?
			nodeKeys = for node in [rel.subject, rel.object]
				nodeType = if node is rel.subject then 'AlchemySubject' else 'AlchemyObject'
				nodeText = Neo4jUtils.escapeCypherValue node.text
				nodeKey = nodeText
				query = "MERGE (node:#{nodeType} {key: #{nodeKey}}) SET node.name = #{nodeText}"
				console.log "neo4j query: #{query}"
				Meteor.neo4j.query query

				id = Neo4jUtils.nextCypherId()
				nodeId = id
				query = "MATCH (#{nodeId}:#{nodeType} {key: #{nodeKey}}) "
				merges = []

				for e in node.entities or []
					id = Neo4jUtils.nextCypherId(id)
					entityType = e.type
					entityName = if e.disambiguated? then e.disambiguated.name else e.text
					entityKey = Neo4jUtils.escapeCypherValue "#{entityType}|#{entityName}"
					props =
						text: e.text
						name: entityName

					if e.disambiguated?
						d = e.disambiguated
						#TODO props.subTypes = d.subType
						#TODO add missing props
						props.dbpedia = d.dbpedia
						props.freebase = d.freebase
						props.opencyc = d.opencyc
						props.yago = d.yago
						props.ciaFactbook = d.ciaFactbook

					set = 'SET'
					setAssignments = for prop, val of props
						if val?
							escapedVal = Neo4jUtils.escapeCypherValue val
							set += ',' unless set == 'SET'
							set += " #{id}.#{prop} = #{escapedVal}"
					merges.push "MERGE (#{id}:#{entityType} {key: #{entityKey}}) #{set}"
					merges.push "MERGE (#{nodeId})-[:INCLUDES]->(#{id})"

				for k in node.keywords or []
					id = Neo4jUtils.nextCypherId(id)
					key = "Keyword|#{k.text}"
					escapedKey = Neo4jUtils.escapeCypherValue key
					props =
						name: k.text

					set = 'SET'
					setAssignments = for prop, val of props
						if val?
							escapedVal = Neo4jUtils.escapeCypherValue val
							set += ',' unless set == 'SET'
							set += " #{id}.#{prop} = #{escapedVal}"
					merges.push "MERGE (#{id}:Keyword {key: #{escapedKey}}) #{set}"
					merges.push "MERGE (#{nodeId})-[:INCLUDES]->(#{id})"

				if merges.length > 0
					query += merges.join(' ')
					console.log "neo4j query: #{query}"
					Meteor.neo4j.query query
				else
					console.warn "empty node: %o", node

				nodeKey

			subjectKey = nodeKeys[0]
			objectKey = nodeKeys[1]

			# action
			a = rel.action
			relType = Neo4jUtils.escapeCypherIdentifier a.lemmatized
			escapedActionText = Neo4jUtils.escapeCypherValue a.text
			escapedActionTense = Neo4jUtils.escapeCypherValue a.verb.tense
			query = "MATCH (s:AlchemySubject {key: #{subjectKey}}),(o:AlchemyObject {key: #{objectKey}}) "+
				"MERGE (s)-[:#{relType} {text: #{escapedActionText}, tense: #{escapedActionTense}}]->(o)"
			console.log "neo4j query: #{query}"
			Meteor.neo4j.query query

		job.done()
		cb()

	workers = SearchQueue.processJobs 'alchemyExtractJob', { concurrency: 1, prefetch: 1, pollInterval: 2500 }, worker
