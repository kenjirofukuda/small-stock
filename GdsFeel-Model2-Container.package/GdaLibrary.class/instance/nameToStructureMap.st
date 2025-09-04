private
nameToStructureMap

	nameToStructureMap ifNil: [ 
		nameToStructureMap := Dictionary new.
		self lookupStructureNames do: [ :structureName | 
			nameToStructureMap
				at: structureName
				ifAbsentPut: [ 
				GdaStructure fromLibrary: self structureNamed: structureName ] ] ].
	^ nameToStructureMap