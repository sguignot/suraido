SearchQueue.setLogStream process.stdout
SearchQueue.promote 2500

Meteor.startup ->
	SearchQueue.startJobs()
