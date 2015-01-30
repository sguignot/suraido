Meteor.publish 'searches', ->
	check this.userId, String # ensure that the user is connected
	return Searches.find({ owner: this.userId })
