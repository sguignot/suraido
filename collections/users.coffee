Meteor.users.attachSchema new SimpleSchema(
	# username:
	# 	type: String
	# 	regEx: /^[a-z0-9A-Z_]{3,15}$/
	# 	optional: true
	emails:
		type: [Object]
		optional: true
	'emails.$.address':
		type: String
		regEx: SimpleSchema.RegEx.Email
	'emails.$.verified':
		type: Boolean
	createdAt:
		type: Date
	services:
		type: Object
		optional: true
		blackbox: true
	roles:
		type: [String]
		optional: true
		blackbox: true
)
