structure control
addStructure: aGdsStructure

	nameToStructureMap ifNil: [ nameToStructureMap := Dictionary new ].
	nameToStructureMap at: aGdsStructure name put: aGdsStructure.
	self clearStructuresCache