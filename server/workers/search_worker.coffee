Meteor.startup ->

	worker = (job, cb) ->
		search = Searches.findOne(_id: job.data.searchId)

		q = search.q
		searchParams =
			q: q
			start: 1 #1+page_index*10
			num: 10
			filter: '1' # remove duplicate content: https://developers.google.com/custom-search/docs/xml_results#automaticFiltering
		
		cache = GoogleCseApiCache.findOne(searchParams)

		if cache?
			response = cache.response
			job.progress 90, 100
			console.log "search cached: #{q}"
		else
			try
				result = HTTP.call('GET', 'https://www.googleapis.com/customsearch/v1',
					params: _.extend({ key: GOOGLE_API_KEY, cx: GOOGLE_SEARCH_ENGINE_ID }, searchParams)
				)
				response = CollectionUtils.fixKeysForMongo(result.data)
				job.progress 90, 100
				console.log "search ok: #{q}"
			catch e
				job.fail "Error from googleapis: #{e}", { fatal: true }
				return cb()

			GoogleCseApiCache.insert _.extend({ response: response }, searchParams)
			console.log "insert cache ok: #{q}"

		for item in response.items
			item._alchemySkip = true if item.mime?

		Searches.update({ _id: search._id }, { $set: { items: response.items }})
		console.log "set items ok: #{q}"

		for item in response.items
			continue if item._alchemySkip
			alchemyJob = SearchQueue.createJob('alchemyExtractJob',
				owner: job.data.owner
				searchId: job.data.searchId
				itemLink: item.link
			)
			alchemyJob.save()

		job.done()
		cb()

	workers = SearchQueue.processJobs 'googleSearchJob', { concurrency: 2, prefetch: 2, pollInterval: 2500 }, worker
