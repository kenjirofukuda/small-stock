"
A GDSreader_0_3_2Test is a test class for testing the behavior of GDSreader_0_3_2
"
Class {
	#name : #'GDSreader_0_3_2Test',
	#superclass : #TestCase,
	#category : #'GdsFeel-SF-Tests'
}

{ #category : #'class tests' }
GDSreader_0_3_2Test >> testDirectoryEntry [
	| directoryEntry |
	directoryEntry := GDSreader_0_3_2 directoryEntry.
	
	self assert: directoryEntry exists.
	self assert: directoryEntry isDirectory.

	
]

{ #category : #'class tests' }
GDSreader_0_3_2Test >> testEnsureCreateTestGdsFile [
	| fileEntry |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.

	
]

{ #category : #'class tests' }
GDSreader_0_3_2Test >> testFileSize [

	| fileEntry |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.
	
	self assert: fileEntry fileSize equals: GDSreader_0_3_2 fileSize.
	
]

{ #category : #'class tests' }
GDSreader_0_3_2Test >> testNumberOfRecords [

	self inform: 'Leave it to GdsStreamFormatReaderTest>>testTestAllRecords'
	
]

{ #category : #'class tests' }
GDSreader_0_3_2Test >> testSampleFileEntry [
	| fileEntry |
	fileEntry := GDSreader_0_3_2 sampleFileEntry.
	
	self assert: fileEntry name equals: 'test.gds'.
	self assert: fileEntry exists.
	self assert: fileEntry isFile.
	

	
]
