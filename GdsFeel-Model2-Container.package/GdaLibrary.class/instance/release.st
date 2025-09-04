initialization
release

	nameToStructureMap ifNotNil: [ 
		nameToStructureMap valuesDo: [ :each | each release ] ].
	nameToStructureMap := nil.
	station := nil.
	super release