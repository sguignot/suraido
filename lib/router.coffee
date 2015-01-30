Router.configure
	layoutTemplate: 'app_layout'
	loadingTemplate: 'loading'
	notFoundTemplate: 'not_found'
	routeControllerNameConverter: 'camelCase'
	onBeforeAction: ->
		@next()

Router.map ->
	@route 'home',
		path: '/'
		waitOn: ->
			[
				Meteor.subscribe 'searchQueue'
				Meteor.subscribe 'searches'
			]
		data:
			searchQueue: ->
				SearchQueue.find({}, {sort: {created: -1}}).fetch()

Router.waitOn ->
	Meteor.subscribe 'user'
