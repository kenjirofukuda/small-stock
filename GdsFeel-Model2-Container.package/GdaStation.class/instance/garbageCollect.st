maintenance
garbageCollect

	self structure ifNotNil: [ 
		^ self inform: 'Cannt garbageCollect: use structure' ].
	self library ifNotNil: [ 
		^ self inform: 'Cannt garbageCollect: use library' ].
	GdaStructure allInstancesDo: [ :s | s allDispose ].
	GdaLibrary allInstancesDo: [ :l | l allDispose ].
	3 timesRepeat: [ Smalltalk garbageCollect ]