Meteor.loadGraphData = ->
	cy = window.cy
	return unless cy?
	gne = Session.get 'graphNodesAndEdges'
	return unless gne?
	nodeIds = {}
	nodes = _.compact _.map(_.union(gne.a, gne.b), (node) ->
		node.id = "#{node.metadata.id}"
		if nodeIds[node.id]
			return null
		else
			nodeIds[node.id] = true
			return { data: node }
	)
	edgeIds = {}
	edges = _.map(gne.r, (edge) ->
		edge.id = "#{edge.metadata.id}"
		edge.source = edge.relation.start
		edge.target = edge.relation.end
		return { data: edge }
	)
	cy.load
		nodes: nodes
		edges: edges


Template.graph.rendered = ->
	$('.cy-graph').cytoscape
		layout:
			name: 'arbor'
		style: cytoscape.stylesheet().selector('node').css(
			'content': 'data(name)'
			).selector(':selected').css(
			'border-width': 3
			'border-color': '#333').selector('edge').css(
			'opacity': 0.666
			'target-arrow-shape': 'triangle'
			'source-arrow-shape': 'circle'
			)
		ready: ->
			window.cy = this
			Tracker.autorun ->
				Meteor.loadGraphData()
			# giddy up
			return


Meteor.startup ->
	Meteor.neo4j.call 'getNodesAndEdges', {}, (error, record) ->
		if error
			 #handle error here
			 throw new Meteor.error '500', 'Something goes wrong here', error.toString()
		else
			Session.set 'graphNodesAndEdges', record
