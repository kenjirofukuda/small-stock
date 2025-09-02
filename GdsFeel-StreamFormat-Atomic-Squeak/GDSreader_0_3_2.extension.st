Extension { #name : #'GDSreader_0_3_2' }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Squeak' }
GDSreader_0_3_2 class >> ensureCreateTestGdsFile [
	" self ensureCreateTestGdsFile"
	| fileEntry |
	fileEntry := self sampleFileEntry.
	fileEntry parent assureExistence.
	fileEntry exists ifFalse: [ 
		| doc data  |
		doc := self sampleFileBinaryURL asUrl retrieveContents.
		data :=  doc contents.
		fileEntry binaryContents:  data asByteArray ].
	^ fileEntry
]
