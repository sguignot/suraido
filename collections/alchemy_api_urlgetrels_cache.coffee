@AlchemyApiUrlgetrelsCache = new Mongo.Collection('alchemy_api_urlgetrels_cache')

AlchemyApiUrlgetrelsCache.attachSchema new SimpleSchema(
	createdAt:
		type: Date
		autoValue: ->
			if this.isInsert
				return new Date()
	url:
		type: String
		index: 1
	maxRetrieve:
		type: Number
	sentiment:
		type: Boolean
	keywords:
		type: Boolean
	entities:
		type: Boolean
	requireEntities:
		type: Boolean
	disambiguate:
		type: Boolean
	linkedData:
		type: Boolean
	coreference:
		type: Boolean
	showSourceText:
		type: Boolean
	sourceText:
		type: String
	response:
		type: Object
		blackbox: true
)
