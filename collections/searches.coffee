@Searches = new Mongo.Collection('searches')

Searches.attachSchema new SimpleSchema(
	createdAt:
		type: Date
		autoValue: ->
			if this.isInsert
				return new Date()
	updatedAt:
		type: Date
		autoValue: ->
			return new Date()
	q:
		type: String
		label: 'Query'
	num:
		type: Number
		defaultValue: 10
		allowedValues: [10, 20, 30, 40]
	lr:
		type: String
		defaultValue: 'lang_en'
	items:
		type: [Object]
		optional: true
		blackbox: true
	owner:
		type: String
		index: 1
		regEx: SimpleSchema.RegEx.Id
		autoValue: ->
			if this.isInsert
				return Meteor.userId()
		autoform:
			options: ->
				_.map Meteor.users.find().fetch(), (user) ->
					label: user.emails[0].address
					value: user._id
)

if Meteor.isServer
	Searches.after.insert (userId, doc) ->
		console.log('Searches.after.insert')
		job = SearchQueue.createJob('googleSearchJob',
			owner: userId
			searchId: doc._id
		)
		job.save()
