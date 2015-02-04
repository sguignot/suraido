Meteor.neo4j.methods
	getNodesAndEdges: () ->
		return  'MATCH (a)-[r:`ACTED_IN`]->(b) RETURN a,b,r'
