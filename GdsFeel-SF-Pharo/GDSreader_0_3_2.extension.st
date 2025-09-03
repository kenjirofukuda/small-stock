Extension { #name : #'GDSreader_0_3_2' }

{ #category : #'*GdsFeel-SF-Pharo' }
GDSreader_0_3_2 class >> ensureCreateTestGdsFile [
	" self ensureCreateTestGdsFile"
	| fileEntry |
	fileEntry := self sampleFileEntry.
	fileEntry parent assureExistence.
	fileEntry exists ifFalse: [ 
		self sampleFileBinaryURL asUrl 
			saveContentsToFile: fileEntry fullPrintString ].
	^ fileEntry
]
