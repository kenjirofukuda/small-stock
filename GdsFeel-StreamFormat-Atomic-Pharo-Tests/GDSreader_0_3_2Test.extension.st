Extension { #name : #'GDSreader_0_3_2Test' }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Pharo-Tests' }
GDSreader_0_3_2Test >> testMD5sum [

	| fileEntry hash |
	fileEntry := GDSreader_0_3_2 ensureCreateTestGdsFile.
	
	self assert: fileEntry exists.
	
	hash := (MD5 hashStream: fileEntry readStream) hex.
	self assert: hash equals: GDSreader_0_3_2 md5sum.
	
]
