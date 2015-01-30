Meteor.publish 'searchQueue', ->
	check this.userId, String # ensure that the user is connected
	return SearchQueue.find({ 'data.owner': this.userId })
