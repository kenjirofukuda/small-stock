*GdsFeel-SF-Squeak
ensureCreateTestGdsFile
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