Meteor.neo4j.methods
	getNodesAndEdges: () ->
		return 'MATCH (a)-[r]->(b) RETURN a,b,r LIMIT 100' # TODO
