# Only allow job owners to manage or rerun jobs
SearchQueue.allow
	manager: (userId, method, params) ->
		ids = params[0]
		unless typeof ids is 'object' and ids instanceof Array
			ids = [ ids ]
		numIds = ids.length
		numMatches = SearchQueue.find({ _id: { $in: ids }, 'data.owner': userId }).count()
		return numMatches is numIds

	jobRerun: (userId, method, params) ->
		id = params[0]
		numMatches = SearchQueue.find({ _id: id, 'data.owner': userId }).count()
		return numMatches is 1

	stopJobs: (userId, method, params) ->
		return userId?


Searches.allow
	insert: (userId, doc) ->
		return userId?
	fetch: ['owner']
