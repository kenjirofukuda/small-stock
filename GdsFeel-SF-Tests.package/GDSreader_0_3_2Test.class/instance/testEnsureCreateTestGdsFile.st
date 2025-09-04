class tests
testEnsureCreateTestGdsFile
	| fileEntry |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.

	