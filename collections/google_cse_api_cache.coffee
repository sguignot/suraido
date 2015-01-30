@GoogleCseApiCache = new Mongo.Collection('google_cse_api_cache')

GoogleCseApiCache.attachSchema new SimpleSchema(
	createdAt:
		type: Date
		autoValue: ->
			if this.isInsert
				return new Date()
	q:
		type: String
		index: 1
	start:
		type: Number
	num:
		type: Number
	filter:
		type: String
	response:
		type: Object
		blackbox: true
)
