Meteor.startup ->
	uniqueNodeTypes = _.union Alchemy.uniqueEntityTypes, ['Subject', 'Object', 'Keyword']

	# TODO?
	# for nodeType in uniqueNodeTypes
	# 	Meteor.neo4j.query "CREATE CONSTRAINT ON (n:#{nodeType}) ASSERT n.key IS UNIQUE"
