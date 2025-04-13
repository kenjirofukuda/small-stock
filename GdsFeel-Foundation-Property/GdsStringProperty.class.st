Class {
	#name : 'GdsStringProperty',
	#superclass : 'GdsObjectProperty',
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsStringProperty class >> typeClass [
	^String
]

{ #category : 'initialize-release' }
GdsStringProperty >> initialize [
	super initialize.
	self initialValue: ''.
]
