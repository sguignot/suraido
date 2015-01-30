@SearchQueue = new JobCollection 'search_queue', { idGeneration: 'MONGO' }

SearchQueue.helpers(
	displayCreated: ->
		return moment(@created).fromNow()
)
