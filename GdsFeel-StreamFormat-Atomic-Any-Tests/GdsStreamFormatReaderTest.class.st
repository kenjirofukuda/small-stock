"
A GdsStreamFormatReaderTest is a test class for testing the behavior of GdsStreamFormatReader
"
Class {
	#name : #GdsStreamFormatReaderTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-StreamFormat-Atomic-Any-Tests'
}

{ #category : #test }
GdsStreamFormatReaderTest >> testAllRecords [

	| testFileEntry reader records1 records2 |
	testFileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	self assert: testFileEntry exists.

	reader := GdsStreamFormatReader fromStreamFormatPath:
		          testFileEntry fullPrintString.
	" first "
	records1 := reader allRecords.
	self assert: records1 notEmpty.

	" second rewind ok?"
	records2 := reader allRecords.
	self assert: records2 notEmpty.

	"currentry not caching"
	self assert: records1 ~~ records2.

	self assert: records1 size equals: GDSreader_0_3_2 numberOfRecords.
	
	self assert: records2 size equals: GDSreader_0_3_2 numberOfRecords
]
