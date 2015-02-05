@ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY || throw "missing env var: ALCHEMY_API_KEY"

@Alchemy =
	# Alchemy API entity types: http://www.alchemyapi.com/api/entity/types/
	entityTypes: [
		'Anatomy'
		'Automobile'
		'Anniversary'
		'City'
		'Company'
		'Continent'
		'Country'
		'Degree'
		'Drug'
		'EmailAddress'
		'EntertainmentAward'
		'Facility'
		'FieldTerminology'
		'FinancialMarketIndex'
		'GeographicFeature'
		'Hashtag'
		'HealthCondition'
		'Holiday'
		'IPAddress'
		'JobTitle'
		'Movie'
		'MusicGroup'
		'NaturalDisaster'
		'OperatingSystem'
		'Organization'
		'Person'
		'PrintMedia'
		'Quantity'
		'RadioProgram'
		'RadioStation'
		'Region'
		'Sport'
		'StateOrCounty'
		'Technology'
		'TelevisionShow'
		'TelevisionStation'
		'TwitterHandle'
	]
	notUniqueEntityTypes: [
		'Anniversary'
		'Quantity'
	]

Alchemy.uniqueEntityTypes = _.difference(Alchemy.entityTypes, Alchemy.notUniqueEntityTypes)
