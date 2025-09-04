class tests
testFileSize

	| fileEntry |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.
	
	self assert: fileEntry fileSize equals: GDSreader_0_3_2 fileSize.
	