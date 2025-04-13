Class {
	#name : 'GdsIntegerProperty',
	#superclass : 'GdsNumberProperty',
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsIntegerProperty class >> typeClass [
	^Integer
]

{ #category : 'initialize-release' }
GdsIntegerProperty >> initialValue: aNumber [
	super initialValue: aNumber asInteger.
]
