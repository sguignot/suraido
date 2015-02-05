Meteor.neo4j.methods
	getNodesAndEdges: () ->
		return 'MATCH (a)-[r]->(b) RETURN a,b,r'
	# testAddPlayer: ->
	# 	return 'CREATE (a:Player {name: {userName}, score: 0})'
