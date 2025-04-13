Class {
	#name : 'GdsFloatProperty',
	#superclass : 'GdsNumberProperty',
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsFloatProperty class >> typeClass [
	^Float
]

{ #category : 'initialize-release' }
GdsFloatProperty >> initialValue: aNumber [
	super initialValue: aNumber asFloat.
]

{ #category : 'initialize-release' }
GdsFloatProperty >> initialize [
	super initialize.
	initialValue := 0.0.

]

{ #category : 'accessing' }
GdsFloatProperty >> setValue: aNumber [ 
	| floatValue |
	self checkType: aNumber kindOf: Number.
	floatValue := aNumber asFloat.
	self checkAccept: floatValue.
	super setValue: floatValue.
]
