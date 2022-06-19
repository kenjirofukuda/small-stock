Class {
	#name : #GplBoundary,
	#superclass : #GplBiContextHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplBoundary class >> methodName [
	^ 'HOGE'
]

{ #category : #'as yet unclassified' }
GplBoundary >> functionCall: aToken [
	^ GdsInteger fromLiteral: 1
]

{ #category : #'as yet unclassified' }
GplBoundary >> procedureCall: aToken [
	self currentItem boundary.
	^ self nullVector
]
