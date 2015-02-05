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
			if Meteor.user()
				return [
					Meteor.subscribe 'searchQueue'
					Meteor.subscribe 'searches'
				]
			else
				return []
		data:
			searchQueue: ->
				SearchQueue.find({}, {sort: {created: -1}}).fetch()

Router.waitOn ->
	Meteor.subscribe 'user'
