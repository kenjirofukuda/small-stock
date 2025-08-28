Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Pharo' }
GdsStreamFormatReader class >> fromStreamFormatPath: aString [

	^ self new setStreamFormatPath: aString
]

{ #category : #'*GdsFeel-StreamFormat-Atomic-Pharo' }
GdsStreamFormatReader >> openForReadFileNamed: aString [

	^ (File openForReadFileNamed: aString)

	
]
