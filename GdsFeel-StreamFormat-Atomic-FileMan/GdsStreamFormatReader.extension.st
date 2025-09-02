Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-Atomic-FileMan' }
GdsStreamFormatReader >> openForReadFileNamed: aString [

	^ aString asFileEntry readStream binary

	
]
