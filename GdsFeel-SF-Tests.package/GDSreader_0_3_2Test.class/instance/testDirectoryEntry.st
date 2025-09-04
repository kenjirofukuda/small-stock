class tests
testDirectoryEntry
	| directoryEntry |
	directoryEntry := GDSreader_0_3_2 directoryEntry.
	
	self assert: directoryEntry exists.
	self assert: directoryEntry isDirectory.

	