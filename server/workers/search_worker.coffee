Meteor.startup ->

	worker = (job, cb) ->
		search = Searches.findOne(_id: job.data.searchId)

		q = search.q
		lr = search.lr
		responseItems = []

		progressCompleted = 0
		progressTotal = search.num // 10 + 1

		for start in [1..search.num] by 10
			searchParams =
				q: q
				start: start
				num: 10
				lr: lr
				filter: '1' # remove duplicate content: https://developers.google.com/custom-search/docs/xml_results#automaticFiltering
			
			cache = GoogleCseApiCache.findOne(searchParams)

			if cache?
				response = cache.response
				console.log "search cached: #{q}"
			else
				try
					result = HTTP.call('GET', 'https://www.googleapis.com/customsearch/v1',
						params: _.extend({ key: GOOGLE_API_KEY, cx: GOOGLE_SEARCH_ENGINE_ID }, searchParams)
					)
					response = CollectionUtils.fixKeysForMongo(result.data)
					console.log "search ok: #{q}"
				catch e
					job.fail "Error from googleapis: #{e}", { fatal: true }
					return cb()

				GoogleCseApiCache.insert _.extend({ response: response }, searchParams)
				console.log "insert cache ok: #{q}"

			for item in response.items
				item._alchemySkip = true if item.mime?

			responseItems = _.union(responseItems, response.items)
			progressCompleted += 1
			job.progress progressCompleted, progressTotal

		Searches.update({ _id: search._id }, { $set: { items: responseItems }})
		console.log "set items ok: #{q}"

		# create search in the graph DB
		searchKey = Neo4jUtils.escapeCypherValue search._id
		searchName = Neo4jUtils.escapeCypherValue search.q
		searchOwner = Neo4jUtils.escapeCypherValue search.owner
		query = "MERGE (s:Search {key: #{searchKey}}) SET s.name = #{searchName}, s.owner = #{searchOwner}"
		console.log "neo4j query: #{query}"
		Meteor.neo4j.query query

		for item in responseItems
			continue if item._alchemySkip

			# create doc in the graph DB
			docKey = Neo4jUtils.escapeCypherValue item.link
			query = "MERGE (d:Document {key: #{docKey}}) SET d.name = #{docKey}"
			console.log "neo4j query: #{query}"
			Meteor.neo4j.query query

			# link doc to the search in the graph DB
			query = "MATCH (search:Search {key: #{searchKey}}),(doc:Document {key: #{docKey}}) "+
				"MERGE (search)-[:HAS_RESULT]->(doc)"
			console.log "neo4j query: #{query}"
			Meteor.neo4j.query query

			# create extract job
			alchemyJob = SearchQueue.createJob('alchemyExtractJob',
				owner: job.data.owner
				searchId: job.data.searchId
				itemLink: item.link
			)
			alchemyJob.save()

		progressCompleted += 1
		job.progress progressCompleted, progressTotal

		job.done()
		cb()

	workers = SearchQueue.processJobs 'googleSearchJob', { concurrency: 2, prefetch: 2, pollInterval: 2500 }, worker
