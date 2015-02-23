Template.search_queue_item.helpers(
	taskDescription: ->
		taskDesc = switch @type
			when 'alchemyExtractJob' then "Extract relations from #{@data.itemLink}"
			when 'googleSearchJob'
				search = Searches.findOne(_id: @data.searchId)
				if search?
					"Search '#{search.q}' (#{search.num} results)"
				else
					"Search ?"
		return taskDesc

	progressPercent: ->
		Math.floor @progress.percent
)
