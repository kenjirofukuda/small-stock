Class {
	#name : #GdsIntegral,
	#superclass : #GdsNumber,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsIntegral class >> acceptRegexPattern [
	^'[-]?[0-9]+'
]

{ #category : #'as yet unclassified' }
GdsIntegral class >> fromSmalltalk: aObject [
	^GdsInteger new stringValue: aObject asString.
]

{ #category : #'as yet unclassified' }
GdsIntegral class >> isAcceptableSmalltalkObject: anObject [
	^anObject isInteger.
]
