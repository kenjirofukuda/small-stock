Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-Atomic-Pharo' }
GdsStreamFormatReader class >> fromStreamFormatPath: aString [

	"self exampleInstance"

	| inst |
	inst := self new stream:
		        (File openForReadFileNamed: aString).
	^ inst
]
