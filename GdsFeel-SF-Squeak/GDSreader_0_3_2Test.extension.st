Extension { #name : #'GDSreader_0_3_2Test' }

{ #category : #'*GdsFeel-SF-Squeak-Tests' }
GDSreader_0_3_2Test >> testMD5sum [

	| fileEntry hash |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.
	
	hash := WebUtils md5Digest: fileEntry binaryContents.
	self assert: (hash sameAs: GDSreader_0_3_2 md5sum).
	
]
