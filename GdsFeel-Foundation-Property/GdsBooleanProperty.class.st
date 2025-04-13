Class {
	#name : 'GdsBooleanProperty',
	#superclass : 'GdsObjectProperty',
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'as yet unclassified' }
GdsBooleanProperty class >> typeClass [ 
	^Boolean
]

{ #category : 'initialize-release' }
GdsBooleanProperty >> initialize [
	super initialize.
	initialValue := false.
]

{ #category : 'actions' }
GdsBooleanProperty >> toggle [
	self setValue: self getValue not.
]
