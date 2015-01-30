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
				job.fail "Error from googleapis: #{e}", { fatal: true }
				return cb()

			AlchemyApiUrlgetrelsCache.insert _.extend({ response: response }, params)
			console.log "insert cache ok: #{url}"

		# TODO: create Neo4J entities/relations

		Searches.update({ _id: search._id }, { $set: { items: response.items }})
		console.log "set items ok: #{url}"

		job.done()
		cb()

	workers = SearchQueue.processJobs 'alchemyExtractJob', { concurrency: 1, prefetch: 1, pollInterval: 2500 }, worker
