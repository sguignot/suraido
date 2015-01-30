Meteor.publish 'user', ->
	Meteor.users.find this.userId
