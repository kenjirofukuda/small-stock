instance creation
initializeName: aString databaseUnits: anInteger unitString: aUnitString

	self checkLibName: aString.
	self checkDatabaseUnit: anInteger.
	self checkUnitString: aUnitString.
	^ self new
		  name: aString
		  databaseUnit: anInteger
		  unitString: aUnitString