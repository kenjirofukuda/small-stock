class tests
testSampleFileEntry
	| fileEntry |
	fileEntry := GDSreader_0_3_2 sampleFileEntry.
	
	self assert: fileEntry name equals: 'test.gds'.
	self assert: fileEntry exists.
	self assert: fileEntry isFile.
	

	